class AssetType < ActiveRecord::Base

  acts_as_enumerated :order=>'position ASC'
  
end
