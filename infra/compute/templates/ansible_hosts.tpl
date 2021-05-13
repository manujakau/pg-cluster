${node_name} ansible_user=${ansible_user} ansible_ssh_pass=${ansible_ssh_pass} ansible_host=${ip}
[${env_name}:vars]
psql_v=${psql_version}
self_ip=${ip}
import_ip=${ip2}
import_ip2=${ip3}