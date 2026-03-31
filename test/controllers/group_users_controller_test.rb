require "test_helper"

class GroupUsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get group_users_index_url
    assert_response :success
  end

  test "should get new" do
    get group_users_new_url
    assert_response :success
  end

  test "should get create" do
    get group_users_create_url
    assert_response :success
  end

  test "should get destroy" do
    get group_users_destroy_url
    assert_response :success
  end
end
