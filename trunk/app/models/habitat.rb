class Habitat < ActiveRecord::Base
  
  acts_as_enumerated :order=>'position ASC'
  
end
