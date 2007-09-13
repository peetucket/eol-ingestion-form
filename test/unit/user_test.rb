require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @user = User.find(1)
  end
  
  # Replace this with your real tests.
  def test_read
    assert_kind_of User, @user
    assert_equal users(:default_user).id, @user.id
    assert_equal users(:default_user).email, @user.email
  end
  
end
