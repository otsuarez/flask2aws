package "git"
package "uwsgi-plugin-python"
package "python-setuptools"

directory "/var/www/flask/appstack" do
  owner "ubuntu"
  group "root"
  mode "0755"
  action :create
end

directory "/tmp/.appstack_deploy/.ssh" do
  owner "ubuntu"
  recursive true
end
 
cookbook_file "/tmp/.appstack_deploy/wrap-ssh4git.sh" do
  source "wrap-ssh4git.sh"
  owner "ubuntu"
  mode 0700
end

cookbook_file "/tmp/.appstack_deploy/.ssh/id_deploy" do
  source "id_deploy"
  owner "ubuntu"
  mode 0600
end

#deploy "private_repo" do
git "/var/www/flask/appstack" do
  repository "git@github.com:otsuarez/flask-blog.git"
  user "ubuntu"  
  #deploy_to "/var/www/flask/appstack"
  #action :deploy
  action :checkout
  ssh_wrapper "/tmp/.appstack_deploy/wrap-ssh4git.sh"
  #symlinks Hash.new
end

execute "install_pip" do
    command "easy_install pip"
    user "root"
end

execute "install_requirements" do
    cwd "/var/www/flask/appstack/"
    user "root"
    command "pip install -r /var/www/flask/appstack/requirements.txt"
end

execute "install_flup" do
    command "pip install flup"
    user "root"
end
