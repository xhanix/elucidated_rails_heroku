class CreateUser
  def self.call(email_address, key, name)

    user = User.find_by(email: email_address)

    return user if user.present?


    user = User.create!(
      email: email_address,
      fullname: name,
    )
    user.description = key
    user.save
    return user
  end
end