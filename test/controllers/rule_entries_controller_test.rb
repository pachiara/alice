require 'test_helper'

class RuleEntriesControllerTest < ActionController::TestCase
  setup do
    @rule_entry = rule_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rule_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rule_entry" do
    assert_difference('RuleEntry.count') do
      post :create, rule_entry: { license_id: @rule_entry.license_id, order: @rule_entry.order, plus: @rule_entry.plus }
    end

    assert_redirected_to rule_entry_path(assigns(:rule_entry))
  end

  test "should show rule_entry" do
    get :show, id: @rule_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rule_entry
    assert_response :success
  end

  test "should update rule_entry" do
    put :update, id: @rule_entry, rule_entry: { license_id: @rule_entry.license_id, order: @rule_entry.order, plus: @rule_entry.plus }
    assert_redirected_to rule_entry_path(assigns(:rule_entry))
  end

  test "should destroy rule_entry" do
    assert_difference('RuleEntry.count', -1) do
      delete :destroy, id: @rule_entry
    end

    assert_redirected_to rule_entries_path
  end
end
