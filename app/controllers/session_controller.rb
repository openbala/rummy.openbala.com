class SessionController < ApplicationController
  before_filter :authenticate, :except => :create
  layout "standard"
#  caches_action :index

  def create
    auth = request.env['rack.auth']
    self.token = auth["credentials"]["token"] if auth["provider"] == 'facebook'
    unless @auth = Authorization.find_from_hash(auth)
      picture_url = self.fb_graph.get_picture("me") if auth["provider"] == 'facebook'
      picture_url = auth["user_info"]["image"] if auth["provider"] == 'twitter'
      @auth = Authorization.create_from_hash(auth, picture_url, current_user)
    end
    self.current_user = @auth.user
    self.current_auth = @auth
    redirect_to :action => 'index'
  end

  def destroy
    session[:user_id] = nil
    session[:token] = nil
    session[:friend_ids] = nil
    session[:uid] = nil
    session[:rank] = nil
    redirect_to root_path
  end

  def index
    if (self.current_auth.provider == 'facebook')
      my_friends ||= self.fb_graph.get_connections("me", "friends")
      ids = Array.new
      my_friends.each { |friend| ids.push(friend["id"]) }
      authorizationz = Authorization.find(:all, :conditions => ["uid in (?)", ids])
      self.set_friends(authorizationz)
      page = params[:page] ? params[:page] : 1;
      @authorizations = authorizationz.paginate(:page => page, :per_page => Authorization.per_page)
    end
  end
end
