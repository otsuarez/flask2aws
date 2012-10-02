current_dir = File.dirname(__FILE__)
log_level :info
log_location STDOUT
cache_type 'BasicFile'
cache_options( :path => "#{current_dir}/checksums" )
cookbook_path ["#{current_dir}/../cookbooks", "#{current_dir}/../site-cookbooks"]
chef_server_url 'https://chef.acme.net'
validation_client_name 'chef-validator'
validation_key "#{current_dir}/validation.pem"
node_name 'otsuarez'
client_key "#{current_dir}/otsuarez-acme.pem"

# EC2
knife[:aws_access_key_id] = ENV["acme_aws_access_key_id"] 
knife[:aws_secret_access_key] = ENV["acme_aws_secret_access_key"] 
knife[:aws_ssh_key_id] = "acmeec2"
