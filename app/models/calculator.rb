class Calculator < ApplicationRecord
  class CyclicError < StandardError
  end

  class XLSEvaluator
    ALPHABET = ('A'..'Z').to_a
    REF_REGEX = /^([A-Z]+)([0-9]+)$/

    def initialize(instructions, row_size)
      @cells = {}

      instructions.each_slice(row_size).with_index do |row, row_number|  
        row.each_with_index do |value, col_number|                       
          location = [ALPHABET[col_number], row_number + 1].join         
          @cells[location] = value                                       
        end 
      end

    end


    def evaluate
      @cells.each do |loc, value|
        # p "location #{loc} value #{value}"
        begin
          @cells[loc] = evaluate_cell(loc, value)
        rescue => e
          raise e
        end
      end
      # output final result
      
      result_values = []
      @cells.values.each do |val|
        # puts val
        # puts sprintf('%.5f', val)
        x = sprintf('%.5f', val)
        result_values << x
      end 

      return result_values
    end

    def evaluate_cell(loc, value, cells_traversed = [loc])
      evaluation = []

      value.to_s.split.each do |term|

        if reference_match = term.match(REF_REGEX)
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
  end
end
