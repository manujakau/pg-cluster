data "template_file" "shell-script-bastion" {
  template = file("scripts/bastion.sh")
}

data "template_cloudinit_config" "cloudinit-bastion" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script-bastion.rendered
  }
}


data "template_file" "shell-script-application" {
  template = file("scripts/application.sh")
}

data "template_cloudinit_config" "cloudinit-application" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script-application.rendered
  }

}


data "template_file" "shell-script-pgmaster" {
  template = file("scripts/pg_master.sh")
}

data "template_cloudinit_config" "cloudinit-pgmaster" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script-pgmaster.rendered
  }

}


data "template_file" "shell-script-pgslave" {
  template = file("scripts/pg_slave.sh")
}

data "template_cloudinit_config" "cloudinit-pgslave" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script-pgslave.rendered
  }

}