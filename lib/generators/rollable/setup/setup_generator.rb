require 'rails/generators'
require 'rails/generators/migration'

module Rollable
  module Generators
    class SetupGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      desc "Sets up rollable, creates model and migration"
      source_root(File.expand_path('../templates', __FILE__))

      def copy_role_model_template
        template 'role.rb', 'app/models/role.rb'
      end

      def copy_role_migration_template
        migration_template 'migration.rb', "db/migrate/create_roles.rb"
      end

      def some_notes
        puts <<-END
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Rollable has been succesfully installed!

        Note that rollable is still in its early stages. Rollable does not
        and will not ever define authorization semantics.
        Its purely intended for agnostic roles between objects only.

        If you like it, leave a note or feel free to contribute!

        To use rollable, make sure you add:

          include Rollable::Base
          rollables <model names>, <options>

        in #{class_name}!

        Have fun,
        Timon Vonk
        END
      end

      private
      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end
    end
  end
end


