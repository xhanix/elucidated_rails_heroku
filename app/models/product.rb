class Product < ApplicationRecord
	has_attached_file :file
	has_many :sales
	validates_numericality_of :price,
    greater_than: 49,
    message: "must be at least 50 cents"
end
