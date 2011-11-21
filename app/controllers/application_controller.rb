class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_session_id
  
  private
  def set_session_id
    @session_id ||= session.id
  end
end
