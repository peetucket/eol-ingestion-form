class Entry < ActiveRecord::Base
  
  include GeoKit::Mappable

  belongs_to :organism
  belongs_to :user
  
  has_many :images
  has_many :assets, :dependent => :delete_all
  has_many :data_points, :dependent => :delete_all
  has_enumerated :habitat
   
  validates_presence_of :date, :message=>"^Please enter the observation date."
  validates_presence_of :user_id
  validates_presence_of :organism_id
  validates_presence_of :habitat_id
  
  validates_date :date, :before => Proc.new { 1.day.from_now.to_date }
  
  validates_numericality_of :lat, :message=>"^Latitude must be a number."
  validates_numericality_of :lon, :message=>"^Longitude must be a number."
  validates_numericality_of :number, :message=>"^Please enter the number seen as an integer.", :only_integer=>true
  validates_numericality_of :temperature, :message=>"^Please enter a numeric temperature.", :allow_nil=>true
  validates_numericality_of :salinity, :message=>"^Please enter a numeric salinity.", :allow_nil=>true

  validates_numericality_of :confidence_range, :message=>"^The confidence range of your observation location must be a number."

  validates_inclusion_of :lat, :in=> -90..90, :message=>"^Latitude must be between -90 and 90 degrees"
  validates_inclusion_of :lon, :in=> -180..180, :message=>"^Longitude must be between -180 and 180 degrees"

  validates_inclusion_of :number, :in=> 1..10000, :message=>"^Number seen must be at least 1"


  acts_as_mappable      :distance_field_name => :distance,
                        :lat_column_name=>"lat", :lng_column_name => "lon"
                        
  def distance_kms
    # convert distance in miles to distance in kilometers
   self.distance.to_f * 1.609344                     
  end
 
  def displayed_location
  
      if self.location.length < 3 
         "Location:" + self.location
       else  
          self.location
       end     
  end

end
