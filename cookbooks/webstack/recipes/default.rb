require_recipe "mysql::server"
require_recipe "database"
require_recipe "webstack::appstack"


package "python-mysqldb"


mysql_database node[:webstack][:appname] do
  connection ({:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']})
  action :create
end

# create connection info as an external ruby hash
mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

#SQLALCHEMY_DATABASE_URI = 'mysql://flaskuser:asecretpass@localhost/myflask'
mysql_database_user 'flaskuser' do
  connection mysql_connection_info
  password 'asecretpass'
  action :create
end

mysql_database_user 'flaskuser' do
  connection mysql_connection_info
  password 'asecretpass'
  database_name node[:webstack][:appname]
  host '%'
  action :grant
end

#node[:webstack][:appname] = node[:][:appname]
# Chef::Log.debug("###############################################################")
# Chef::Log.debug("#{node[:appstack][:appname]}")
# Chef::Log.debug("#{node[:webstack][:appname]}")
