class SubjectsLookupController < ApplicationController

  def index
    @label = params[:label].to_s
    @per_page = params[:limit].to_i
    @per_page = 200 unless (1..200).include?(@per_page)
    @from = params[:from].to_i

    @subjects = subjects_with_labels_starting(@label, @per_page, @from)

    @total_count = count_subjects_with_labels_starting(@label)

    view
  end

  def show
    @label = params[:id]
    @per_page = 200
    @from = params[:from].to_i

    @subjects = subjects_with_labels_starting(params[:id], @per_page, @from)
    @total_count = count_subjects_with_labels_starting(@label)


    view
  end

  private

  def view
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

  def count_subjects_with_labels_starting(label)
    Subject
      .where(["LOWER(label) LIKE ? ", label.downcase + '%'])
      .count
  end

  def subjects_with_labels_starting(label, limit=50, from)
    Subject
      .select(:id, :label, :records_count)
      .where(["LOWER(label) LIKE ? ", label.downcase + '%'])
      .order('records_count desc')
      .offset(@from)
      .limit(limit)
  end

end
