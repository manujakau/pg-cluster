data "template_file" "ansible_app_host" {
  count = 1
  template   = file("${path.root}/compute/templates/ansible_hosts.tpl")
  depends_on = [aws_instance.db_master_host]

  vars = {
    node_name    = aws_instance.db_master_host.*.tags[count.index]["Name"]
    ansible_user = var.remote_user
    ansible_ssh_pass = var.remote_password
    ip           = "${join(", ", aws_instance.db_master_host.*.private_ip)}"
  }
}

data "template_file" "ansible_skeleton" {
  template = file("${path.root}/compute/templates/ansible_skeleton.tpl")

  vars = {
    web_hosts_def = join("", data.template_file.ansible_app_host.*.rendered)
  }
}


resource "local_file" "ansible_inventory" {
  depends_on = [data.template_file.ansible_skeleton]

  content  = data.template_file.ansible_skeleton.rendered
  filename = "${path.root}/compute/inventory"
}

resource "null_resource" "provisioner" {
  depends_on = [local_file.ansible_inventory]

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "${path.root}/compute/inventory"
    destination = "~/inventory"

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
  depends_on = [null_resource.provisioner]

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
    null_resource.provisioner,
    aws_instance.db_master_host,
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
      "echo 'ssh is up...'",
      "sleep 120 && ansible-playbook -i ~/inventory ~/ansible/playbook.yml ",
    ]
  }
}
