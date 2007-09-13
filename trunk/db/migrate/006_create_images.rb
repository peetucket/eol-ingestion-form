class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :entry_id, :integer
      t.column :user_id, :integer
      t.column :parent_id, :integer
      t.column :content_type, :string
      t.column :filename, :string    
      t.column :thumbnail, :string 
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer 
       
      t.foreign_key :entry_id, :entries, :id, :on_delete => :set_null, :on_update => :cascade
      t.foreign_key :user_id, :users, :id, :on_delete => :set_null, :on_update => :cascade     
    end
  end

  def self.down
    drop_table :images
  end
end
