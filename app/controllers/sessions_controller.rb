class SessionsController < ApplicationController

  def new
    reset_session
  end

  def create

    user = User.find_by(email: params[:email])
    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      puts "Saving session as #{user.id}"
      redirect_to root_path
    else
      redirect_to new_session_path
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end

end
