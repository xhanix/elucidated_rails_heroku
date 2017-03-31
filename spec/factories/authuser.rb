FactoryGirl.define do
  factory :authuser do |f|
    f.email	{ Faker::Internet.email } 
    password '12345678'
    password_confirmation '12345678'
  end
end