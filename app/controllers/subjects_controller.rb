class SubjectsController < ApplicationController

  def index
    @top_subjects = Subject
      .order('records_count desc')
      .limit(200)
  end

  def show
    id = params[:id].gsub('S','')

    @subject = Subject.find(id)

    @things = @subject.records.select(:identifier, :title, :package)
      .order('digitized desc')
      .limit(100)


    thing_ids = @subject.records.pluck(:id)

    @people_whove_written_about_it = Person
      .joins(:creators)
      .select("people.*, count(creators.id) as count")
      .where(creators: {record_id: thing_ids})
      .group('people.id')
      .order('count desc')
      .limit(20)

    @related_subjects = Subject
      .joins(:taggings)
      .select("subjects.*, count(subjects.id) as count")
      .where(taggings: {record_id: thing_ids})
      .where.not(id: @subject.id)
      .group('subjects.id')
      .order('count desc')
      .limit(15)


    @trees = []

    @narrower_subjects = []

    @subject.tree_numbers.to_a.each do |tree_number|

      parent_tree_numbers = [tree_number]

      tree_number = tree_number.gsub(/\.?[^\/\.]+\z/, '')

      while !tree_number.blank?

        tree_number = tree_number.gsub(/\.?[^\/\.]+\z/, '')
        parent_tree_numbers << tree_number unless tree_number.blank?

      end

      @trees << Subject.select('*')
      .from("(select *, unnest(tree_numbers) as tree_number from subjects) as subjects")
      .where(tree_number: parent_tree_numbers)
      .order(:tree_number)

    end

    @subject.tree_numbers.to_a.each do |tree_number|

      Subject.select('*')
        .from("(select id, records_count, label, unnest(tree_numbers) as tree_number from subjects) as subjects")
        .where(["tree_number LIKE ?", tree_number + '.%'])
        .order('records_count desc')
        .limit(10)
        .each do |subject|

        @narrower_subjects << subject unless @narrower_subjects.include?(subject)

      end

    end

  end

end
