class Organism < ActiveRecord::Base
  
  has_many :entries, :order=>"date DESC", :dependent => :delete_all
  has_many :organism_infos, :order=>"date DESC", :limit=>1, :dependent => :delete_all
  has_many :data_points
  
  validates_uniqueness_of :name
  validates_presence_of :name

end
