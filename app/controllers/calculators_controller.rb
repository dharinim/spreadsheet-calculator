class CalculatorsController < ApplicationController
  ALPHABET = ('A'..'Z').to_a
  REF_REGEX = /^([A-Z]+)([0-9]+)$/
  def index

  end

  def show_result
    p "printing spreadsheet values"
    p params[:json].flatten
    data = params[:json].flatten
    p params[:col_count]
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

          if cells_traversed.include? term
            cells_traversed << term 
            raise "cyclic dep detectected. trace: #{cells_traversed.join(' >> ')}"
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
    
    result_values = []
  # go through and evaluate each cell 
    @cells.each do |loc, value|
      p "location #{loc} value #{value}"
      @cells[loc] = evaluate_cell(loc, value)
    end
  # output final result
    
    @cells.values.each do |val|
      # puts val
      # puts sprintf('%.5f', val)
      x = sprintf('%.5f', val)
      result_values << x
    end 
    p result_values
    new_result = []
    result_values.each_slice(row_size){|a| new_result << a}
    p "new result is #{new_result}"
    # render :js => result_values
    # respond_with(result_values)
    respond_to do |format|
      format.json { render json: new_result, status: :ok }
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
#       }