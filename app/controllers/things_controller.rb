class ThingsController < ApplicationController

  def show
    @thing = Record.find_by!(identifier: params[:id])
    @subjects = @thing.subjects
    @collections = @thing.collections.not_hidden
    @people_as_subjects = @thing.people_as_subjects

    if @thing.archives_ref

      @child_records = Record
        .select(:identifier, :title)
        .where(parent_id: @thing.id)
        .order(:title)
        .limit(500)
    end
  end

end
