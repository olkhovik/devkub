resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 50"
  }

  depends_on = [
    null_resource.inventories
  ]
}

resource "null_resource" "public_access" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i kubespray/inventory/mycluster/inventory.ini ansible/supplementary_addresses_in_ssl_keys.yml -b -v"
  }

  depends_on = [
    null_resource.wait
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i kubespray/inventory/mycluster/inventory.ini kubespray/cluster.yml -b -v"
  }

  depends_on = [
    null_resource.public_access
  ]
}

resource "null_resource" "hello_node" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i kubespray/inventory/mycluster/inventory.ini ansible/playbook.yml -b -v"
  }

  depends_on = [
    null_resource.cluster
  ]
}