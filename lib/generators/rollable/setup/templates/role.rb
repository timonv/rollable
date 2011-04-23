class Role < ActiveRecord::Base
  belongs_to :<%= plural_name.singularize %>
  belongs_to :rollable, :polymorphic => true
end