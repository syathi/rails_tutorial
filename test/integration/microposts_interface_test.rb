require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  
  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select "div.pagination"
    assert_select 'input[type=FILL_IN]'
    #無効な送信
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: {content: "" }}
    end
    assert_select "div#error_explanation"
    #有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('text/fixtures/rails.png', 'image/png')
    assert_difference "Micropost.count" do
      post microposts_path, micropost: { content: content, picture: FILL_IN }
    end
    assert FILL_IN.picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    #投稿を削除
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end
    #違うユーザのプロフィールにアクセス（削除リンクが無いことを確認)
    get user_path(users(:archer))
    assert_select "a", text: "delete", count: 0
  end
end