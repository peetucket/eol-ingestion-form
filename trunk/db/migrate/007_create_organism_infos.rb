class CreateOrganismInfos < ActiveRecord::Migration
  def self.up
    create_table :organism_infos do |t|
       t.column :organism_id, :integer
       t.column :user_id, :integer
       t.column :date, :datetime
       t.column :description, :text, :default=>"" 

       t.foreign_key :user_id, :users, :id, :on_delete => :set_null, :on_update => :cascade
       t.foreign_key :organism_id, :organisms, :id, :on_delete => :cascade, :on_update => :cascade
    end
  end

  def self.down
    drop_table :organism_infos
  end
end
