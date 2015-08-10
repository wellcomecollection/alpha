class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter do
    set_cache_header(60 * 60 * 24 * 7)  # 7 days
  end

  private

  def set_cache_header(seconds)
    unless Rails.env.to_s == 'development'
      response.headers = {"Cache-Control" => "public, max-age=#{seconds}"}
    end
  end

end
