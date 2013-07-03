require 'test_helper'

class DetectionsControllerTest < ActionController::TestCase
  setup do
    @detection = detections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:detections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create detection" do
    assert_difference('Detection.count') do
      post :create, detection: { name: @detection.name, product_id: @detection.product_id }
    end

    assert_redirected_to detection_path(assigns(:detection))
  end

  test "should show detection" do
    get :show, id: @detection
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @detection
    assert_response :success
  end

  test "should update detection" do
    put :update, id: @detection, detection: { name: @detection.name, product_id: @detection.product_id }
    assert_redirected_to detection_path(assigns(:detection))
  end

  test "should destroy detection" do
    assert_difference('Detection.count', -1) do
      delete :destroy, id: @detection
    end

    assert_redirected_to detections_path
  end
end
