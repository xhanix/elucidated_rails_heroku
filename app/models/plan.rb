class Plan < ApplicationRecord
	has_paper_trail
	belongs_to :product
    validates :stripe_id, uniqueness: true
end
