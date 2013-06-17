require 'test_helper'

class TypeLicensesControllerTest < ActionController::TestCase
  setup do
    @type_license = type_licenses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:type_licenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create type_license" do
    assert_difference('TypeLicense.count') do
      post :create, type_license: { code: @type_license.code, description: @type_license.description }
    end

    assert_redirected_to type_license_path(assigns(:type_license))
  end

  test "should show type_license" do
    get :show, id: @type_license
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @type_license
    assert_response :success
  end

  test "should update type_license" do
    put :update, id: @type_license, type_license: { code: @type_license.code, description: @type_license.description }
    assert_redirected_to type_license_path(assigns(:type_license))
  end

  test "should destroy type_license" do
    assert_difference('TypeLicense.count', -1) do
      delete :destroy, id: @type_license
    end

    assert_redirected_to type_licenses_path
  end
end
