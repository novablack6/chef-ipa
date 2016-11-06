property :request_name, String, name_property: true

property :key_path, String, required: true
property :cert_path, String, required: true

property :key_user, String, default: 'root'
property :key_group, String, default: 'root'

property :key_type, equal_to: ['RSA', 'DSA', 'EC']
property :key_size, Fixnum

getcert_cmd = ['ipa-getcert']


action :create do
  getcert_cmd += ['request']
  # Allow key generation parameters to be specified
  unless key_type.nil?
    getcert_cmd += ['-G', key_type]
  end
  unless key_size.nil?
    getcert_cmd += ['-g', key_size]
  end

  getcert_cmd += ['-k', key_path]
  getcert_cmd += ['-f', cert_path]
  execute "certificate request #{request_name}" do
    command getcert_cmd
    creates cert_path
  end

  file "#{request_name} private key" do
    owner key_user
    group key_group
    path key_path
    subscribes :create, "execute[certificate reqeust #{request_name}", :immediate
  end

  file "#{request_name} certificate" do
    owner key_user
    group key_group
    path cert_path
    subscribes :create, "execute[certificate reqeust #{request_name}", :immediate
  end
end