class SubjectsLookupController < ApplicationController

  def index
    @label = params[:label].to_s
    limit = params[:limit]

    @subjects = subjects_with_labels_starting(@label, limit)

    respond_to do |format|
      format.html do
        if (@subjects.length == 1)
          redirect_to subject_path(@subjects.first)
        else
          render :show
        end
      end
      format.json { render json: @subjects.collect(&:to_api) }
    end
  end

  def show
    @label = params[:id]
    @subjects = subjects_with_labels_starting(params[:id])
    respond_to do |format|
      format.html do
        if (@subjects.length == 1)
          redirect_to subject_path(@subjects.first)
        else
          render :show
        end
      end
      format.json { render json: @subjects.collect(&:to_api) }
    end
  end

  private

  def subjects_with_labels_starting(label, limit=50)
    Subject
      .select(:id, :label, :records_count)
      .where(["LOWER(label) LIKE ? ", label.downcase + '%'])
      .order('records_count desc')
      .limit(limit)
  end

end
