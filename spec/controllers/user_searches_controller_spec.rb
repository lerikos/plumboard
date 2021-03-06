require 'login_user_spec'

describe UserSearchesController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
  end

  describe 'GET /index' do
    context 'load users' do
      it_behaves_like 'searches controller index', 'User', 'users'
    end
  end
end
