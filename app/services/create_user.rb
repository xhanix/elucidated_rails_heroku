class CreateUser
  def self.call(email_address, key)

    user = User.find_by(email: email_address)

    return user if user.present?


    user = User.create!(
      email: email_address,
    )
    user.description = key
    user.save
    return user
  end
end