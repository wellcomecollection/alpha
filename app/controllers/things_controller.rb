class ThingsController < ApplicationController

  def show
    @thing = Record.find_by!(identifier: params[:id])
    @subjects = @thing.subjects

    if @thing.archives_ref

      @child_records = Record
        .select(:identifier, :title)
        .where(parent_id: @thing.id)
        .order(:title)
        .limit(500)
    end
  end

end
