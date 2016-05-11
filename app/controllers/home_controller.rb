class HomeController < ApplicationController

  def show
    @subjects = Subject
      .highlighted
      .order('random()')

    @people = Person
      .highlighted
      .order('random()')

    @collections = Collection
      .highlighted
      .order('random()')

  end

end
