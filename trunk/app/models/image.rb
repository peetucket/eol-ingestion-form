class Image < ActiveRecord::Base

  belongs_to :entry
  belongs_to :user
  
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :min_size => 1.kilobytes,
                 :max_size => 500.kilobytes,
                 :resize_to => '640x480>',
                 :processor => 'MiniMagick',
                 :path_prefix => 'public/uploaded_images',
                 :thumbnails => { :thumb => '90x90>' }

# :processor => 'Rmagick'  if using rmagick

  validates_as_attachment
  
end
