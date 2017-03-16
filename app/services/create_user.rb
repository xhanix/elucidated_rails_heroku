class CreateUser
  def self.call(email_address, key, fullname)

    user = User.find_by(email: email_address)

    return user if user.present?


    user = User.create!(
      email: email_address,
    )
    user.description = key
    user.fullname = fullname
    user.save
    return user
  end
end