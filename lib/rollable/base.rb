# TODO: Because of the endless blocks, some calls are too nested, needs to be fixed. Even more seperate methods
# in seperate files would clean in up.
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
        
        set_target_model_helpers
        set_relations_on_rollables
        set_role_validations
        set_role_setter_helpers
      end

      private

      def set_role_setter_helpers
        rollables = @rollables
        @role_names.each do |name|
          define_method("is_#{name}") do |object|
            if rollables.include?(object.class.to_s)
              self.roles.create!(:rollable => object, :name => name)
            else
              false
            end
          end
        end
      end
                

      # DISCLAIMER: Headache and on the airport, hush.
      # Helpers for target models like has_owner? and get_owners
      def set_target_model_helpers
        other = self
        @rollables.select { |r| r.is_a?(String) }.each do |model|
          model = model.constantize
          @role_names.each do |role_name|
            model.class_eval do
              define_method("has_#{role_name}?") do
                self.roles.where("name = ? ", role_name).count > 0
              end

              # TODO: get_#{role_name} doesn't sound very rubyish
              define_method("get_#{role_name.pluralize}") do
                self.roles.where("name = ? ", role_name).collect { |r| r.send(other.to_s.downcase) }
              end
            end
          end
        end
      end

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
            # TODO: Check should be made earlier
            raise "#{model} is not an ActiveRecord object!"  #Again, just to be sure and nice.
          end
        end
      end
    end

    # TODO: Don't need method_missing no more, use dynamic dispatch instead.
    def method_missing(method, *args)
      if method =~ /^is_([a-z]+)(?:_(?:on|of))?\?$/ #Common spell to match against regex
        role = $1
        that_thing = args.first.presence
        object = that_thing.class.to_s if that_thing
        self.class_eval do #Open my class definition
          if that_thing
            define_method(method) do |thing| # Define the method. Helps a lot in performance
              self.roles.where("rollable_type = ? AND name = ?", object, role).inject(false) do |v,o| # You can't do an inner join on polymorphic relationships, unfortunately.
                v ||= (o.rollable == thing)
              end
            end
          else
            define_method(method) do
              self.roles.where("name = ?", role).count > 0
            end
          end
        end
        if that_thing
          self.public_send(method, that_thing) # And of course, call the method.
        else
          self.public_send(method)
        end
      else
        super
      end
    end

    def respond_to?(method, include_private=false)
      if method =~ /^is_([a-z]+)(?:_(?:on|of))?\?$/
        self.class.role_names.include?($1)
      else
        super
      end
    end
  end
end
