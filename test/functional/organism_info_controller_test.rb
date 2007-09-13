require File.dirname(__FILE__) + '/../test_helper'
require 'organism_info_controller'

# Re-raise errors caught by the controller.
class OrganismInfoController; def rescue_action(e) raise e end; end

class OrganismInfoControllerTest < Test::Unit::TestCase
  def setup
    @controller = OrganismInfoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
