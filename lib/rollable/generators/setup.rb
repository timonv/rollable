module Rollable
  class Setup < Rails::Generators::NamedBase
    desc "Sets up rollable, creates model"

    def create_role_model
      generate("model", "Role name:string #{file_name}:references rollable:references")
    end
  end
end


