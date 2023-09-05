# frozen_string_literal: true

require 'test_helper'

class VarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @var = vars(:one)
  end

  test 'should get index' do
    get vars_url
    assert_response :success
  end

  test 'should get new' do
    get new_var_url
    assert_response :success
  end

  test 'should create var' do
    assert_difference('Var.count') do
      post vars_url, params: { var: { description: @var.description, name: @var.name, value: @var.value } }
    end

    assert_redirected_to var_url(Var.last)
  end

  test 'should show var' do
    get var_url(@var)
    assert_response :success
  end

  test 'should get edit' do
    get edit_var_url(@var)
    assert_response :success
  end

  test 'should update var' do
    patch var_url(@var), params: { var: { description: @var.description, name: @var.name, value: @var.value } }
    assert_redirected_to var_url(@var)
  end

  test 'should destroy var' do
    assert_difference('Var.count', -1) do
      delete var_url(@var)
    end

    assert_redirected_to vars_url
  end
end
