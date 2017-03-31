FactoryGirl.define do
  factory :subscription do |f|
  	association :user, :factory => :user
  	association :plan, :factory => :plan
  	f.stripe_id {Faker::Number.number(12)} 
  	f.guid {Faker::Number.number(10)}
  end
end