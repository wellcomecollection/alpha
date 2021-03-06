class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session

  # before_filter do
  #   set_cache_header(60 * 60 * 24 * 7)  # 7 days
  # end

  def current_user
    @current_user ||= User.find(cookies.encrypted[:user_id]) if cookies.encrypted[:user_id]
  end

  def logged_in_as_admin?
    current_user.try(:admin)
  end

  helper_method :current_user, :logged_in_as_admin?

  def authorize
    redirect_to new_session_path unless current_user.try(:admin)
  end


  rescue_from(ActiveRecord::RecordNotFound) do
    render :template => "errors/not_found", :status => 404
  end

  private

  def set_cache_header(seconds)
    unless Rails.env.to_s == 'development'
      response.headers = {"Cache-Control" => "public, max-age=#{seconds}"}
    end
  end

end
