module Rollable
  module Base
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def rollables(*models)
        models.each do |model|
          model = model.to_s.camelize.constantize #Accepting symbols looks nicer than constants, so we need to convert them
          if model.ancestors.include?(ActiveRecord::Base)  #Check if it is an actual rails model, just to be sure
            model.class_eval do # Enter the given models class
              has_many :roles, :as => 'rollable'  # Define the relationship <img src="http://www.timonv.nl/wp-includes/images/smilies/icon_smile.gif" alt=":-)" class="wp-smiley">
            end
          else
            raise "Bzzp, #{model} is not an ActiveRecord object!"  #Again, just to be sure and nice.
          end
        end
        Role.class_eval do
          validates_inclusion_of :rollable_type, :in => models.collect!(&:to_s) # Programmers are stupid, so lets help them out.
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
  end
end
