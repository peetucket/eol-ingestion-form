require 'digest/sha2'

class User < ActiveRecord::Base

  validates_uniqueness_of :email
  validates_presence_of :fullname
  validates_format_of :email, :with =>%r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i
  attr_protected :admin, :active, :password_salt, :password_hash

  has_many :entries
  has_many :data_points
  has_many :images
  has_many :assets

  has_many :organisms, :through => :entries, :select => "DISTINCT organisms.*", :order=>"name"
  
  before_destroy :check_user
    
  def check_user
    raise 'You cannot remove this user.' if $MAGIC_USERS.include?(self.email)
    raise 'You cannot remove a user that has entries.' if self.entries.count>0
  end
    
  def password=(pass)
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_salt, self.password_hash =
      salt, Digest::SHA256.hexdigest(pass + salt)
  end
  
  def self.authenticate(email, password)
    user = User.find(:first, :conditions => ['email = ?', email])
    if user.blank? || Digest::SHA256.hexdigest(password + user.password_salt) != user.password_hash
      raise "The email address or password you have entered is invalid.  Passwords are case sensitive." 
    end
    if user.active?
      user
    else
      raise "Your account is not currently active.  Contact us to re-activate your account."
    end
  end
    
end
