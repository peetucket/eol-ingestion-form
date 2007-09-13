class CreateHabitats < ActiveRecord::Migration
  def self.up
    create_table :habitats do |t|
       t.column :name, :string
       t.column :position, :integer
    end
  end

  def self.down
    drop_table :habitats
  end
end
