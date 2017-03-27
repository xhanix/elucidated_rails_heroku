FactoryGirl.define do
  factory :user do |f|
  	f.fullname { Faker::Name.first_name }
  	f.email { Faker::Internet.email }
  end
end
