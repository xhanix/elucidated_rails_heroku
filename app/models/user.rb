class User < ApplicationRecord
	attr_encrypted :description, key: Rails.configuration.stripe[:secret_key], encode: true, encode_iv: true, encode_salt: true
	validates :fullname,:email, presence: true
end
