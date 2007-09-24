class UserActivationCode < ActiveRecord::Migration
  def self.up
    add_column :users,:activate_code,:string,:null=>true
  end

  def self.down
    remove_column :users,:activate_code
  end
end
