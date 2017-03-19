class CreateUser
  def self.call(email_address, key, fullname)

    user = User.find_by(email: email_address)

    return user if user.present?
    user = User.create!(
      email: email_address,
      fullname: fullname,
      description: key
    )
    user.save
    return user
  end
end