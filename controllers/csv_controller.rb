class CsvController < ApplicationController
  def index
    data = ParamData.new(:customer_id, :locmotive_id)
    
    @datas = data.search_for

  end
end
