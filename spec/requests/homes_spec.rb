require 'rails_helper'

describe 'home page' do
  it 'shows eLucidaid' do
    visit '/'
    expect(page).to have_content('eLucidaid')
  end
end