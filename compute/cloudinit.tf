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