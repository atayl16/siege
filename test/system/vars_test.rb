# frozen_string_literal: true

require 'application_system_test_case'

class VarsTest < ApplicationSystemTestCase
  setup do
    @var = vars(:one)
  end

  test 'visiting the index' do
    visit vars_url
    assert_selector 'h1', text: 'Vars'
  end

  test 'should create var' do
    visit vars_url
    click_on 'New var'

    fill_in 'Description', with: @var.description
    fill_in 'Name', with: @var.name
    fill_in 'Value', with: @var.value
    click_on 'Create Var'

    assert_text 'Var was successfully created'
    click_on 'Back'
  end

  test 'should update Var' do
    visit var_url(@var)
    click_on 'Edit this var', match: :first

    fill_in 'Description', with: @var.description
    fill_in 'Name', with: @var.name
    fill_in 'Value', with: @var.value
    click_on 'Update Var'

    assert_text 'Var was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Var' do
    visit var_url(@var)
    click_on 'Destroy this var', match: :first

    assert_text 'Var was successfully destroyed'
  end
end
