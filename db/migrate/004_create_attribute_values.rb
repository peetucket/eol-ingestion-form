class CreateAttributeValues < ActiveRecord::Migration
  def self.up
    create_table :attribute_values do |t|
      t.column :name, :string, :null=>false
    end
  end

  def self.down
    drop_table :attribute_values
  end
end
