[all:vars]
ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

[dbslave]
${db_slave_def}