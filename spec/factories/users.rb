FactoryGirl.define do
  factory :user do |f|
  	f.fullname { Faker::Name.first_name }
  	f.email { Faker::Internet.email }
  	f.stripe_customer_id ''
  end
end
