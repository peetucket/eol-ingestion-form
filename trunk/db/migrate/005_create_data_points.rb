class CreateDataPoints < ActiveRecord::Migration
  def self.up
    create_table :data_points do |t|
      t.column :attribute_value_id, :integer
      t.column :entry_id, :integer
      t.column :value, :string, :null=>false
  
      t.foreign_key :attribute_value_id, :attribute_values, :id, :on_delete => :cascade, :on_update => :cascade 
      t.foreign_key :entry_id, :entries, :id, :on_delete => :cascade, :on_update => :cascade     
    end
  end

  def self.down
    drop_table :data_points
  end
end
