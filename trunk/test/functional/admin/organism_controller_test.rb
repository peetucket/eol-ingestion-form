require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/organism_controller'

# Re-raise errors caught by the controller.
class Admin::OrganismController; def rescue_action(e) raise e end; end

class Admin::OrganismControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::OrganismController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
