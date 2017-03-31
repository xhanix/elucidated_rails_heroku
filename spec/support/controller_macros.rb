module ControllerMacros
  def login_authuser
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:authuser]
      sign_in FactoryGirl.create(:authuser) # Using factory girl as an example
    end
  end
  def login_licenseuser
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:licenseuser]
      sign_in FactoryGirl.create(:licenseuser) # Using factory girl as an example
    end
  end
end