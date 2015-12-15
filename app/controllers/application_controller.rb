class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # before_filter do
  #   set_cache_header(60 * 60 * 24 * 7)  # 7 days
  # end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def authorize
    redirect_to new_session_path unless current_user.try(:admin)
  end

  private

  def set_cache_header(seconds)
    unless Rails.env.to_s == 'development'
      response.headers = {"Cache-Control" => "public, max-age=#{seconds}"}
    end
  end

end
