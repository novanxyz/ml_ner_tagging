
# add default user
core_user = Admin::CoreUser.new
core_user.email = 'admin@gmail.com'
core_user.username = 'admin'
core_user.password = 'password'
core_user.firstname = 'Admin'
core_user.lastname = 'App'
core_user.save