require 'securerandom'


class CyclicError < StandardError
end

class CalculatorsController < ApplicationController
  ALPHABET = ('A'..'Z').to_a
  REF_REGEX = /^([A-Z]+)([0-9]+)$/
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


    # p params[:xls_data].flatten
    data = params[:xls_data].flatten
    # p params[:col_count]
    col_count = params[:col_count]

    instructions = data
    row_size = col_count

    @cells = {}

    instructions.each_slice(row_size).with_index do |row, row_number|  
      row.each_with_index do |value, col_number|                       
        location = [ALPHABET[col_number], row_number + 1].join         
        @cells[location] = value                                       
      end 
    end

    def evaluate_cell(loc, value, cells_traversed = [loc])
      evaluation = []

      value.to_s.split.each do |term|

        if reference_match = term.match(REF_REGEX)
          flash = {}
          if cells_traversed.include? term
            cells_traversed << term 
            raise CyclicError.new("cyclic dep detectected. trace: #{cells_traversed.join(' >> ')}")
          else
            going_deeper = cells_traversed.clone
            going_deeper << term
            result = evaluate_cell(loc, @cells[term], going_deeper).to_f

            # cache result so we don't need to calculate again
            @cells[term] = result

            evaluation << result
          end
        elsif ["-", "/", "*", "+", "**"].include?(term)
          operands = evaluation.pop(2)
          evaluation << operands[0].send(term, operands[1])
        else
          evaluation << term.to_f
        end
      end
      return evaluation.first
    end
    
  if flash.keys.count == 0
      result_values = []
    # go through and evaluate each cell 
      @cells.each do |loc, value|
        # p "location #{loc} value #{value}"
        begin
          @cells[loc] = evaluate_cell(loc, value)
        rescue CyclicError => e
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
      end
    # output final result
      
      @cells.values.each do |val|
        # puts val
        # puts sprintf('%.5f', val)
        x = sprintf('%.5f', val)
        result_values << x
      end 
      # p result_values
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

      # p "new result is #{new_result}"
      # render :js => result_values 
      # respond_with(result_values)
      respond_to do |format|
        format.json { render json: new_result, status: :ok }
      end
    end
  end
end

# format.js { render             
#         # raw javascript to be executed on client-side
#         "alert('Hello Rails');", 
#         # send HTTP response code on header
#         :status => 404 # page not found,
#         # load /app/views/your-controller/different_action.js.erb
#         :action => "different_action",
#         # send json file with @line_item variable as json
#         :json => @line_item,
#         :file => filename,
#         :text => "OK",
#         # the :location option to set the HTTP Location header
#         :location => path_to_controller_method_url(argument)
#       

