class TypesController < ApplicationController

  def index
    @types = Type.order('records_count desc')
  end

  def show
    @type = Type.find(params[:id].gsub('T',''))

    @records = @type.records.select(:identifier, :title).limit(100)
  end

end
