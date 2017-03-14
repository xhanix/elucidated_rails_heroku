class Product < ApplicationRecord
	has_many :sales
 
	validates_numericality_of :price,
        greater_than: 49,
        message: "must be at least 50 cents"
    has_attached_file :file
    validates_attachment_content_type :file, :content_type => [
    "image/jpg",
    "image/jpeg",
    "image/png",
    "image/gif",
    "application/pdf",
    "application/zip"
    ]
end
