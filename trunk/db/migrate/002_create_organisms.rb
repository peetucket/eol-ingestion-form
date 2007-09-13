class CreateOrganisms < ActiveRecord::Migration
  def self.up
    create_table :organisms do |t|
       t.column :namebank_id, :string
       t.column :union_id, :string
       t.column :name, :string, :null=>false
    end
  end

  def self.down
    drop_table :organisms
  end
end
