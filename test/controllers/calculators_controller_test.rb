require 'test_helper'

class CalculatorsControllerTest < ActionDispatch::IntegrationTest
  test "show_result fails when no xls data is sent" do
    post "/calculators", as: :json

    expectedRepsonse = {
      "error_code"=>"no_xls_data_found",
      "message"=>"No xls data was submitted."
    }

    assert_equal 500, response.status
    assert_equal expectedRepsonse, JSON.parse(response.body)
  end

  test "show_result fails when no col count data is sent" do
    post_params = { 
      xls_data: [["1", "2", "3"]]
    }

    post "/calculators", params: post_params, as: :json

    expectedRepsonse = {
      "error_code"=>"no_col_data_found",
      "message"=>"No col_count data was submitted."
    }

    assert_equal 500, response.status
    assert_equal expectedRepsonse, JSON.parse(response.body)
  end

  test "show_result success when data is sent" do
    post_params = { 
      xls_data: [["1", "2", "3"]],
      col_count: 3
    }

    post "/calculators", params: post_params, as: :json
    # post :create, {:post => data}
    # post :create, {:post => {}, :user => {:email => 'abc@abcd'} }
    assert_equal 200, response.status
    assert_equal [["1.00000","2.00000","3.00000"]], JSON.parse(response.body)
  end

  test "show_result success when single cell data is sent" do
    post_params = { 
      xls_data: [["1"]],
      col_count: 1
    }

    post "/calculators", params: post_params, as: :json
    # post :create, {:post => data}
    # post :create, {:post => {}, :user => {:email => 'abc@abcd'} }
    assert_equal 200, response.status
    assert_equal [["1.00000"]], JSON.parse(response.body)
  end

  test "show_result evaluates polish notations" do
    post_params = { 
      xls_data: [["100 10 +", "2", "3"]],
      col_count: 3
    }

    post "/calculators", params: post_params, as: :json
    # post :create, {:post => data}
    # post :create, {:post => {}, :user => {:email => 'abc@abcd'} }
    assert_equal 200, response.status
    assert_equal [["110.00000","2.00000","3.00000"]], JSON.parse(response.body)
  end

  test "show_result evaluates with polish notations and references" do
    post_params = { 
      xls_data: [["100 10 +", "2", "A1"]],
      col_count: 3
    }

    post "/calculators", params: post_params, as: :json
    # post :create, {:post => data}
    # post :create, {:post => {}, :user => {:email => 'abc@abcd'} }
    assert_equal 200, response.status
    assert_equal [["110.00000","2.00000","110.00000"]], JSON.parse(response.body)
  end

  test "show_result evaluates with references" do
    post_params = { 
      xls_data: [["1", "2", "A1"]],
      col_count: 3
    }

    post "/calculators", params: post_params, as: :json
    # post :create, {:post => data}
    # post :create, {:post => {}, :user => {:email => 'abc@abcd'} }
    assert_equal 200, response.status
    assert_equal [["1.00000","2.00000","1.00000"]], JSON.parse(response.body)
  end

  test "show_result evaluates with cyclic references" do
    post_params = { 
      xls_data: [["A1", "1", "2"]],
      col_count: 3
    }

    expectedRepsonse = {
      "error_code"=>"cyclic_dependency",
      "message"=>"cyclic dep detectected. trace: A1 >> A1"
    }

    post "/calculators", params: post_params, as: :json
    # post :create, {:post => data}
    # post :create, {:post => {}, :user => {:email => 'abc@abcd'} }
    assert_equal 500, response.status
    assert_equal expectedRepsonse, JSON.parse(response.body)
  end

  test "show_result evaluates with strange error" do
    #todo: Fix code as this error should never be raise
    post_params = { 
      xls_data: [["1", "A1", "A2"]],
      col_count: 3
    }

    expectedRepsonse = {
      "error_code"=>"some_random_error",
      "message"=>"can't add a new key into hash during iteration"
    }

    post "/calculators", params: post_params, as: :json
    # post :create, {:post => data}
    # post :create, {:post => {}, :user => {:email => 'abc@abcd'} }
    assert_equal 500, response.status
    assert_equal expectedRepsonse, JSON.parse(response.body)
  end
end
