maintainer        "Acme, Inc."
maintainer_email  "cloud@acme.com"
license           "Apache 2.0"
description       "Installs and configures a flask app web stack"
version           "0.000.1"

recipe "webstack", "Installs and configures all the required services required for a flask app to work"

%w{ ubuntu debian }.each do |os|
  supports os
end

%w{ nginx uwsgi database mysql appstack }.each do |cb|
  depends cb
end
