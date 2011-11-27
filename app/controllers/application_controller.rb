class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_session_id
  
  private
  def set_session_id
    session[:user_auth] ||= session.id
    @session_id = session[:user_auth]
  end
end
