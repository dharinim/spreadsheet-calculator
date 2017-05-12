require 'securerandom'

class CalculatorsController < ApplicationController
  def index

  end

  def show_result
    if params[:xls_data] == nil
      response_data = {
          error_code: "no_xls_data_found",
          message: "No xls data was submitted."
      }

      return respond_to do |format|
        format.json { render json: response_data, status: :error }
      end

    elsif params[:col_count] == nil || params[:col_count] == 0
      response_data = {
          error_code: "no_col_data_found",
          message: "Please enter data to evalute"
      }

      return respond_to do |format|
        format.json { render json: response_data, status: :error }
      end
    end


    data = params[:xls_data].flatten
    col_count = params[:col_count]

    instructions = data
    row_size = col_count

    xls_evalutor = Calculator::XLSEvaluator.new(instructions, row_size)

    begin
      evaluate_cells = xls_evalutor.evaluate
    rescue Calculator::CyclicError => e
        response_data = {
            error_code: "cyclic_dependency",
            message: e.message
        }

        return respond_to do |format|
          format.json { render json: response_data, status: :error }
        end
    rescue => e
        response_data = {
            error_code: "some_random_error",
            message: e
        }

        return respond_to do |format|
          format.json { render json: response_data, status: :error }
        end
    end

    # generating a unique key so that we can retrieve this data again
    # e.g. /calculators/uNiQueID will retrieve the specific evaluated sheet
    unique_url_identifier = SecureRandom.hex
    Calculator.store_evaluated_instructions(evaluate_cells, row_size, unique_url_identifier)
   
    new_result = []
    evaluate_cells.each_slice(row_size){|a| new_result << a}
    
    respond_to do |format|
      format.json { render json: new_result, status: :ok }
    end
  end 
end


