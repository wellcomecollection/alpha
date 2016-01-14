class SessionsController < ApplicationController

  def new
    cookies.delete(:user_id)
  end

  def create

    user = User.find_by(email: params[:email])
    if user.try(:authenticate, params[:password])
      cookies.encrypted[:user_id] = {value: user.id, expires: 30.days.from_now}
      puts "Saving session as #{user.id}"
      redirect_to root_path
    else
      redirect_to new_session_path
    end
  end

  def destroy
    cookies.delete(:user_id)
    redirect_to root_path
  end

end
