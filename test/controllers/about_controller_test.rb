require 'test_helper'

class AboutControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get alice" do
    get :alice
    assert_response :success
  end

#  test "should get lispa" do
#    get :lispa
#    assert_response :success
#  end

end
