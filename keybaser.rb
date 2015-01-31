class Keybaser
  def self.login(username, password)
    new Keybase::Core::User.login(username, password)
  end

  def initalize(user)
    @user = user
  end

  def private_key
    @user.basics.private_keys.primary
  end

end
