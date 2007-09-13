class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.column :organism_id, :integer
      t.column :user_id, :integer
      t.column :habitat_id, :integer     
      t.column :number, :integer, :null=>false, :default=>1
      t.column :lat, :float, :null=>false
      t.column :lon, :float, :null=>false
      t.column :location, :string, :null=>false, :default=>""
      t.column :date, :datetime
      t.column :temperature, :float
      t.column :salinity, :float
      t.column :description, :text, :default=>"" 
      t.column :confidence_range,:float, :null=>false, :default=>0
      t.column :confidence_range_units,:string, :null=>false, :default=>"miles"
      
      t.foreign_key :organism_id, :organisms, :id, :on_delete => :set_null, :on_update => :cascade
      t.foreign_key :user_id, :users, :id, :on_delete => :set_null, :on_update => :cascade
    end
  end

  def self.down
    drop_table :entries
  end
end
