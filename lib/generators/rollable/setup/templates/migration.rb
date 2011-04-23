class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.references :<%= plural_name.singularize %>
      t.references :rollable, :polymorphic => true
      t.timestamps
    end
  end
  
  def self.down
    drop_table :roles
  end
end

