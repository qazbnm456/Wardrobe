class IndexController < ApplicationController
  before_action :authenticate_user!, except: [:index, :about]

  def index
    redirect_to store_path
  end

  def store
    @user = current_user
  end

  def about
  end
end
