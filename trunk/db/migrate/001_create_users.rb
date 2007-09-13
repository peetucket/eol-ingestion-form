class CreateUsers < ActiveRecord::Migration
  
  def self.up
    create_table :users do |t|
      t.column :password_salt, :string
      t.column :password_hash, :string
      t.column :email, :string, :default=>'',:null=>false 
      t.column :fullname, :string, :default=>'',:null=>false 
      t.column :institution, :string, :default=>''
      t.column :address, :text, :default=>''
      t.column :active, :boolean, :default=>true, :null=>false                          
      t.column :admin, :boolean, :default=>false, :null=>false
    end
 end

  def self.down
    drop_table :users
  end
end
