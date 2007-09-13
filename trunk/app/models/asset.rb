class Asset < ActiveRecord::Base

  belongs_to :entry
  belongs_to :user
  has_enumerated :asset_type

end
