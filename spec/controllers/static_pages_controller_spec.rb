require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
	describe 'GET #home' do
		subject { get :home }
		it "renders the application template" do
	      	get :home
	      	expect(subject).to render_template(:application)
	   end
	   it "renders the home template" do
	      	get :home
	      	expect(subject).to render_template(:home)
	   end
   end

   

end
