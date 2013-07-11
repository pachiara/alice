require 'test_helper'

class DetectedComponentsControllerTest < ActionController::TestCase
  setup do
    @detected_component = detected_components(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:detected_components)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create detected_component" do
    assert_difference('DetectedComponent.count') do
      post :create, detected_component: { component_id: @detected_component.component_id, license_id: @detected_component.license_id, license_name: @detected_component.license_name, license_version: @detected_component.license_version, name: @detected_component.name, version: @detected_component.version }
    end

    assert_redirected_to detected_component_path(assigns(:detected_component))
  end

  test "should show detected_component" do
    get :show, id: @detected_component
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @detected_component
    assert_response :success
  end

  test "should update detected_component" do
    put :update, id: @detected_component, detected_component: { component_id: @detected_component.component_id, license_id: @detected_component.license_id, license_name: @detected_component.license_name, license_version: @detected_component.license_version, name: @detected_component.name, version: @detected_component.version }
    assert_redirected_to detected_component_path(assigns(:detected_component))
  end

  test "should destroy detected_component" do
    assert_difference('DetectedComponent.count', -1) do
      delete :destroy, id: @detected_component
    end

    assert_redirected_to detected_components_path
  end
end
