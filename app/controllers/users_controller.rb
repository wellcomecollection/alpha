class UsersController < ApplicationController

  before_filter :authorize

  def index
    @users = User.order(:email).limit(100)
  end

  def new
    @user = User.new
  end

  def create

    @user = User.new

    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.admin = true
    @user.password_confirmation = nil

    if @user.save
      redirect_to users_path
    else

      puts @user.errors.full_messages
      redirect_to new_user_path
    end

  end

end
