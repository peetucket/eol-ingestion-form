class OrganismInfo < ActiveRecord::Base

  belongs_to :organism
  belongs_to :user
  
  validates_presence_of :date
  validates_presence_of :description
  validates_presence_of :user_id
  validates_presence_of :organism_id
    
end
