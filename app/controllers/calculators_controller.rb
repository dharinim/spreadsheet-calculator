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

    elsif params[:col_count] == nil
      response_data = {
          error_code: "no_col_data_found",
          message: "No col_count data was submitted."
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
      result_values = xls_evalutor.evaluate
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

      new_result = []
      result_values.each_slice(row_size){|a| new_result << a}
      
      random_string = SecureRandom.hex

      result_values.each_slice(row_size).with_index do |row, row_number|  
        row.each_with_index do |value, col_number|                       
          location = col_number, row_number + 1  
          #p col_number, row_number, value, random_string
          calcultor = Calculator.create(data: value, col_index: col_number, row_index: row_number, url_gen: random_string)                                   
        end 
      end

     
      respond_to do |format|
        format.json { render json: new_result, status: :ok }
      end
    end
end


