class CalculatorsController < ApplicationController
  def index

  end

  def show_result
    p "printing spreadsheet values"
    p params[:json].flatten
    p params[:col_count]
  end
end
