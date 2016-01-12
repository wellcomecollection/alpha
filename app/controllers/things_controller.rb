class ThingsController < ApplicationController

  def show
    @thing = Record.find_by!(identifier: params[:id])
    @subjects = @thing.subjects
  end

end
