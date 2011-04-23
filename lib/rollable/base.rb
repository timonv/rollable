module Rollable
  module Base
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:has_many, :roles)
    end

    module ClassMethods
      def rollables(*models, opts)
        # So we can access it in respond_to?
        @rollables = models.collect { |m| m.to_s.camelize }#Accepting symbols looks nicer than constants, so we need to convert them
        @role_names = opts[:roles] if opts.has_key?(:roles)

        if opts.has_key?(:allow_nil) && opts[:allow_nil]
          @rollables << nil
        end

        self.class_eval do
          # Hackety hack.
          class << self; attr_reader :rollables, :role_names; end;
        end

        set_relations_on_rollables
        set_role_validations
      end

      private
      def set_role_validations
        # Yugh, scope and self, ugly but it works.
        rollables = @rollables
        roles = @role_names
        other = self
        Role.class_eval do
          validates_presence_of other.to_s.downcase + "_id"
          validates_inclusion_of :rollable_type, :in => rollables # Programmers are stupid, so lets help them out.
          if roles.any?
            validates_inclusion_of :name, :in => roles
          end
        end
      end

      def set_relations_on_rollables
        @rollables.select { |r| r.is_a?(String) }.each do |model|
          model = model.constantize
          if model.ancestors.include?(ActiveRecord::Base)  #Check if it is an actual rails model, just to be sure
            model.class_eval do # Enter the given models class
              has_many :roles, :as => 'rollable'  # Define the relationship <img src="http://www.timonv.nl/wp-includes/images/smilies/icon_smile.gif" alt=":-)" class="wp-smiley">
            end
          else
            raise "#{model} is not an ActiveRecord object!"  #Again, just to be sure and nice.
          end
        end
      end
    end

    def method_missing(method, *args)
      if method =~ /^is_(\w+)_(?:on|of)\?$/ #Common spell to match against regex
        role = $1
        that_thing = args.first
        object = that_thing.class.to_s
        self.class_eval do #Open my class definition
          define_method(method) do |thing| # Define the method. Helps a lot in performance
            self.roles.where("rollable_type = ? AND name = ?", object, role).inject(false) do |v,o| # You can't do an inner join on polymorphic relationships, unfortunately.
              v ||= (o.rollable == thing)
            end
          end
        end
        self.public_send(method, that_thing) # And of course, call the method.
      else
        super
      end
    end

    def respond_to?(method, include_private=false)
      if method =~ /^is_(\w+)_(?:on|of)\?$/
        self.class.role_names.include?($1)
      else
        super
      end
    end
  end
end
