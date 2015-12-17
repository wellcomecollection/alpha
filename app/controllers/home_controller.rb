class HomeController < ApplicationController

  def show
    @subjects = Subject
      .highlighted
      .limit(20)
      .order('random()')

    @people = Person
      .highlighted
      .limit(20)
      .order('random()')

  end

end
