class DataPoint < ActiveRecord::Base

  belongs_to :attribute_value
  belongs_to :entry
  
end
