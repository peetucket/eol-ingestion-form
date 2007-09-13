class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
       t.column :entry_id, :integer
       t.column :user_id, :integer
       t.column :asset_type_id, :integer
       t.column :url, :string
       t.column :description, :string

      t.foreign_key :entry_id, :entries, :id, :on_delete => :set_null, :on_update => :cascade
      t.foreign_key :user_id, :users, :id, :on_delete => :set_null, :on_update => :cascade     
 
    end
  end

  def self.down
    drop_table :assets
  end
end
