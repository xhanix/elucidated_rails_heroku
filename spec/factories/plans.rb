FactoryGirl.define do
  factory :plan do |f|
  	f.stripe_id {Faker::Number.number(12)}
  	f.name 'elucidaid-premium-plan'
  end
end