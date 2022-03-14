package 'apt-transport-https'

apt_repository 'erlang' do
  uri 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/ubuntu'
  distribution 'focal'
  components ['main']
  key 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key'
  action :add
end

apt_repository 'rabbitmq' do
  uri 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/deb/ubuntu'
  distribution 'focal'
  components ['main']
  key 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/gpg.9F4587F226208342.key'
  action :add
end

package 'rabbitmq-server'

systemd_unit 'rabbitmq-server.service' do
  action :nothing
end

%w(cert.pem ca-bundle.pem key.pem).each do |c|
  template "/etc/rabbitmq/#{c}" do
    source "certificates/#{c}"
    owner 'rabbitmq'
    group 'rabbitmq'
    mode '0600'
    sensitive true
  end
end

file '/var/lib/rabbitmq/.erlang.cookie' do
  content 'VNQMAWCGVEEOZPKIYFPU'
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '0400'
  sensitive true
  notifies :restart, 'systemd_unit[rabbitmq-server.service]'
end

template '/etc/rabbitmq/enabled_plugins' do
  source 'config/enabled_plugins.erb'
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '0640'
  notifies :restart, 'systemd_unit[rabbitmq-server.service]'
end

template '/etc/rabbitmq/rabbitmq.conf' do
  source 'config/rabbitmq.conf.erb'
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '0640'
  notifies :restart, 'systemd_unit[rabbitmq-server.service]'
end
