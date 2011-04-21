class CreateHorses < ActiveRecord::Migration
  def self.up
    create_table :horses do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :horses
  end
end
