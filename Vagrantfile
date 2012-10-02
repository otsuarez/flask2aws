Vagrant::Config.run do |config|
  config.vm.box = "oneiric32flask"
  # config.vm.box_url = "http://domain.com/path/to/above.box"
  # config.vm.boot_mode = :gui
  #config.vm.network "33.33.33.10" 
  config.vm.network :hostonly, "192.168.50.4"
  #config.vm.forward_port "http", 80, 8080 
  config.vm.forward_port 80, 8080
  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.share_folder "v-data", "/vagrant_data", ".", :nfs => true
  #config.vm.share_folder "foo", "/guest/path", "/host/path"
  config.vm.share_folder "v-root", "/vagrant", ".", :disabled => true


  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks" 
    chef.log_level = "debug"
    chef.add_recipe "webstack" 
    #chef.add_role "web"
    # You may also specify custom JSON attributes:
    #chef.json = { :mysql_password => "foo" }
    #chef.json.merge!({ :webstack => {:appname => "myflask"}
    # nasty nasty workaround for chef-solo
    chef.json = { 
      :webstack => {
        :appname => "appstack",
        :wsgi_app_link_dir => "/var/lib/nginx/uwsgi/",
        :wsgi_app => "wsgi_app.py",
        :uwsgi_ini_dir => "/etc/uwsgi/apps-enabled/",
        :uwsgi_ini_file => "/myflask.ini",
        :deploy_dir => "/var/www/flask/"
      },
      :appstack => {
        :appname => "appstack",
        :deploy_dir => "/var/www/flask/" 
      },
      :mysql => {
        :server_root_password => "mariadb!"
      }
    }
  end
end