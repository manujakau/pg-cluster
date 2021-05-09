data "template_file" "ansible_app_host" {
  count    = 1
  template = file("${path.root}/compute/templates/ansible_hosts.tpl")
  depends_on = [aws_instance.application_host,
    aws_instance.db_master_host
  ]

  vars = {
    node_name        = aws_instance.application_host.*.tags[count.index]["Name"]
    ansible_user     = var.remote_user
    ansible_ssh_pass = var.remote_password
    ip               = "${join(", ", aws_instance.application_host.*.private_ip)}"
    ip2              = "${join(", ", aws_instance.db_master_host.*.private_ip)}"
    env_name         = "webnodes"
    psql_version     = var.psql_version
  }
}
data "template_file" "ansible_skeleton_app" {
  template = file("${path.root}/compute/templates/ansible_skeleton_app.tpl")

  vars = {
    app_hosts_def = join("", data.template_file.ansible_app_host.*.rendered)
  }
}

resource "local_file" "ansible_inventory_app" {
  depends_on = [data.template_file.ansible_skeleton_app]

  content  = data.template_file.ansible_skeleton_app.rendered
  filename = "${path.root}/compute/inventory_app"
}

resource "null_resource" "provisioner_app" {
  depends_on = [local_file.ansible_inventory_app]

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "${path.root}/compute/inventory_app"
    destination = "~/inventory_app"

    connection {
      type     = "ssh"
      host     = aws_instance.bastion_host.public_ip
      user     = var.remote_user
      password = var.remote_password
      insecure = true
    }
  }
}



data "template_file" "ansible_db_master_host" {
  count    = 1
  template = file("${path.root}/compute/templates/ansible_hosts.tpl")
  depends_on = [aws_instance.db_master_host,
    aws_instance.db_slave_host
  ]

  vars = {
    node_name        = aws_instance.db_master_host.*.tags[count.index]["Name"]
    ansible_user     = var.remote_user
    ansible_ssh_pass = var.remote_password
    ip               = "${join(", ", aws_instance.db_master_host.*.private_ip)}"
    ip2              = "${join(", ", aws_instance.db_slave_host.*.private_ip)}"
    env_name         = "dbmaster"
    psql_version     = var.psql_version
  }
}
data "template_file" "ansible_skeleton_dbm" {
  template = file("${path.root}/compute/templates/ansible_skeleton_dbm.tpl")

  vars = {
    db_master_def = join("", data.template_file.ansible_db_master_host.*.rendered)
  }
}

resource "local_file" "ansible_inventory_dbm" {
  depends_on = [data.template_file.ansible_skeleton_dbm]

  content  = data.template_file.ansible_skeleton_dbm.rendered
  filename = "${path.root}/compute/inventory_dbm"
}

resource "null_resource" "provisioner_dbm" {
  depends_on = [local_file.ansible_inventory_dbm]

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "${path.root}/compute/inventory_dbm"
    destination = "~/inventory_dbm"

    connection {
      type     = "ssh"
      host     = aws_instance.bastion_host.public_ip
      user     = var.remote_user
      password = var.remote_password
      insecure = true
    }
  }
}



data "template_file" "ansible_db_slave_host" {
  count    = 1
  template = file("${path.root}/compute/templates/ansible_hosts.tpl")
  depends_on = [aws_instance.db_slave_host,
    aws_instance.db_master_host
  ]

  vars = {
    node_name        = aws_instance.db_slave_host.*.tags[count.index]["Name"]
    ansible_user     = var.remote_user
    ansible_ssh_pass = var.remote_password
    ip               = "${join(", ", aws_instance.db_slave_host.*.private_ip)}"
    ip2              = "${join(", ", aws_instance.db_master_host.*.private_ip)}"
    env_name         = "dbslave"
    psql_version     = var.psql_version
  }
}
data "template_file" "ansible_skeleton_dbs" {
  template = file("${path.root}/compute/templates/ansible_skeleton_dbs.tpl")

  vars = {
    db_slave_def = join("", data.template_file.ansible_db_slave_host.*.rendered)
  }
}

resource "local_file" "ansible_inventory_dbs" {
  depends_on = [data.template_file.ansible_skeleton_dbs]

  content  = data.template_file.ansible_skeleton_dbs.rendered
  filename = "${path.root}/compute/inventory_dbs"
}

resource "null_resource" "provisioner_dbs" {
  depends_on = [local_file.ansible_inventory_dbs]

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "${path.root}/compute/inventory_dbs"
    destination = "~/inventory_dbs"

    connection {
      type     = "ssh"
      host     = aws_instance.bastion_host.public_ip
      user     = var.remote_user
      password = var.remote_password
      insecure = true
    }
  }
}



resource "null_resource" "cp_ansible" {
  depends_on = [
    null_resource.provisioner_app,
    null_resource.provisioner_dbm,
    null_resource.provisioner_dbs
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "${path.root}/compute/ansible"
    destination = "~/"

    connection {
      type     = "ssh"
      host     = aws_instance.bastion_host.public_ip
      user     = var.remote_user
      password = var.remote_password
      insecure = true
    }
  }
}


resource "null_resource" "ansible_run" {
  depends_on = [
    null_resource.cp_ansible,
    null_resource.provisioner_app,
    null_resource.provisioner_dbm,
    null_resource.provisioner_dbs,
    aws_instance.application_host,
    aws_instance.db_master_host,
    aws_instance.db_slave_host,
    aws_instance.bastion_host,
    var.nat_depend,
    var.rt_depend
  ]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type     = "ssh"
    host     = aws_instance.bastion_host.public_ip
    user     = var.remote_user
    password = var.remote_password
    insecure = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Connected To Private Network'",
      "sleep 120 && ansible-playbook -i ~/inventory_app ~/ansible/playbook_app.yml ",
      "sleep 5 && ansible-playbook -i ~/inventory_dbm ~/ansible/playbook_dbm.yml ",
      "sleep 5 && ansible-playbook -i ~/inventory_dbs ~/ansible/playbook_dbs.yml ",
    ]
  }
}
