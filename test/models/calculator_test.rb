require 'test_helper'

class CalculatorTest < ActiveSupport::TestCase
  setup do
    @basic = {
      instructions: ["1", "2", "3"],
      row_size: 3,
      output: ["1.00000", "2.00000", "3.00000"]
    }

    @references = {
      instructions: ["1", "2", "A1"],
      row_size: 3,
      output: ["1.00000", "2.00000", "1.00000"]
    }

    @cyclic = {
      instructions: ["A1", "1", "2"],
      row_size: 3,
    }


    @two_rows = {
      instructions: ["1", "2", "A1", "1", "2", "A1"],
      row_size: 3,
      output: ["1.00000", "2.00000", "1.00000", "1.00000", "2.00000", "1.00000"]
    }

    @lower_case = {
      instructions: ["1", "2", "a1"],
      row_size: 3,
      output: ["1.00000", "2.00000", "0.00000"]
    }

    @lower_case_cyclic = {
      instructions: ["a1", "1", "2"],
      row_size: 3,
      output: ["0.00000", "1.00000", "2.00000"]
    }

    @single_cell = {
      instructions: ["1"],
      row_size: 1,
      output: ["1.00000"]
    }

    @empty_cell = {
      instructions: [],
      row_size: 0,
      output: []
    }

    @complex_polish_notation = {
      instructions: ["B2", "4 3 *", "C2", "A1 B1 / 2 +", "13", "B1 A2 / 2 *"],
      row_size: 3,
      output: ["13.00000", "12.00000", "7.78378", "3.08333", "13.00000", "7.78378"]
    }
  end

  test "Basic test to evaluate successfully" do
    evaluate_test(@basic)
  end

  test "Basic test to evaluate successfully with two rows" do
    evaluate_test(@two_rows)
  end

  test "with references" do
    evaluate_test(@references)
  end

  test "lower case ignores the cell" do
    evaluate_test(@lower_case)
  end

  test "lower case ignores cyclic references" do
    evaluate_test(@lower_case_cyclic)
  end

  test "single cell data" do
    evaluate_test(@single_cell)
  end

  test "empty cell data" do
    evaluate_test(@empty_cell)
  end

  test "complex polish notations" do
    evaluate_test(@complex_polish_notation)
  end

  test "cyclic references" do
    testcase = @cyclic
    xls = Calculator::XLSEvaluator.new(testcase[:instructions], testcase[:row_size])
    assert_raises Calculator::CyclicError do 
      xls.evaluate
    end
  end

  private

  def evaluate_test(testcase)
    xls = Calculator::XLSEvaluator.new(testcase[:instructions], testcase[:row_size])
    assert_equal testcase[:output], xls.evaluate
  end


end
