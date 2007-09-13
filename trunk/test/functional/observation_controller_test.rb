require File.dirname(__FILE__) + '/../test_helper'
require 'observation_controller'

# Re-raise errors caught by the controller.
class ObservationController; def rescue_action(e) raise e end; end

class ObservationControllerTest < Test::Unit::TestCase
  def setup
    @controller = ObservationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
