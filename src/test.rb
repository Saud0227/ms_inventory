require 'bcrypt'

cleartext_password = 'my password'
hashed_password = BCrypt::Password.create(cleartext_password)

p hashed_password