require_recipe "nginx"
require_recipe "uwsgi"

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

app_dir= node[:webstack][:deploy_dir]+node[:webstack][:appname]

template "app-db-config-webstack" do
  path app_dir+"/config.py"
  source "config.py.erb"
  mode 0644
  owner "root"
  group "root"
end

directory app_dir do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

execute "db_initial_sql" do
  command "mysql -u root -p#{node['mysql']['server_root_password']} #{node[:webstack][:appname]} < #{node[:webstack][:deploy_dir]}#{node[:webstack][:appname]}/db/initial.sql"
  "mysql -u root -p#{node['mysql']['server_root_password']} #{node[:webstack][:appname]} < #{node[:webstack][:deploy_dir]}#{node[:webstack][:appname]}/db/initial.sql"
  only_if "test -f #{node[:webstack][:deploy_dir]}#{node[:webstack][:appname]}/db/initial.sql"
end

#node[:webstack][:appname] = node[:][:appname]
# Chef::Log.debug("###############################################################")
# Chef::Log.debug("#{node[:appstack][:appname]}")
# Chef::Log.debug("#{node[:webstack][:appname]}")

wsgi_app_link_target = node[:webstack][:wsgi_app_link_dir]+node[:webstack][:appname]
wsgi_app_link_to = node[:webstack][:deploy_dir]+node[:webstack][:appname]+"/"+node[:webstack][:wsgi_app]

link "wsgi_app" do
    target_file wsgi_app_link_target
    to wsgi_app_link_to
    not_if "test -L #{wsgi_app_link_target}"
end


service "nginx" do
  enabled true
  running true
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
service "uwsgi" do
  enabled true
  running true
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end

uwsgi_ini_target = node[:webstack][:uwsgi_ini_dir]+node[:webstack][:appname]+".ini"

template "uwsgi-app" do
  path uwsgi_ini_target
  source "uwsgi.ini.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "uwsgi")
end

template "nginx-sites-webstack" do
  path "/etc/nginx/sites-available/default"
  source "nginx.site.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "nginx")
end
