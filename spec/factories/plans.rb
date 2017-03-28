FactoryGirl.define do
  factory :plan do |f|
  	f.stripe_id {Faker::Number.number(12)}
  end
end