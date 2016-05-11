class RecentChangesController < ApplicationController

  before_filter :authorize

  def show

    sleep 40

    Struct.new('RecentChange', :updated_at, :updated_by_email, :thing, :field, :thing_id, :thing_name)

    @recent_changes = []

    @recent_changes += Subject
      .where.not(wellcome_intro_updated_at: nil)
      .order(:wellcome_intro_updated_at)
      .reverse_order
      .limit(20)
      .collect {|s|
        Struct::RecentChange.new(
          s.wellcome_intro_updated_at,
          s.wellcome_intro_updated_by.email,
          'subject',
          'intro',
          s.to_param,
          s.label
        )
      }

    @recent_changes += Person
      .where.not(wellcome_intro_updated_at: nil)
      .order(:wellcome_intro_updated_at)
      .reverse_order
      .limit(20)
      .collect {|s|
        Struct::RecentChange.new(
          s.wellcome_intro_updated_at,
          s.wellcome_intro_updated_by.email,
          'person',
          'intro',
          s.to_param,
          s.name
        )
      }

    @recent_changes += Person
      .where.not(editorial_updated_at: nil)
      .order(:editorial_updated_at)
      .reverse_order
      .limit(20)
      .collect {|s|
        Struct::RecentChange.new(
          s.editorial_updated_at,
          s.editorial_updated_by.email,
          'person',
          'editorial',
          s.to_param,
          s.name
        )
      }

    @recent_changes = @recent_changes.sort_by(&:updated_at).reverse

  end

end
