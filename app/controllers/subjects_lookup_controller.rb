class SubjectsLookupController < ApplicationController

  def index
    @label = params[:label].to_s
    @subjects = subjects_with_labels_starting(@label)

    respond_to do |format|
      format.html do
        if (@subjects.length == 1)
          redirect_to subject_path(@subject.first)
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
          redirect_to subject_path(@subject.first)
        else
          render :show
        end
      end
      format.json { render json: @subjects.collect(&:to_api) }
    end
  end

  private

  def subjects_with_labels_starting(label)
    Subject
      .select(:id, :label, :records_count)
      .where(["LOWER(label) LIKE ? ", label.downcase + '%'])
      .order('records_count desc')
      .limit(50)
  end

end
