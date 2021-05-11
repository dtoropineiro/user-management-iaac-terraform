resource "google_compute_address" "static_db" {
  name = "ipv4-address-db"
}


// VM with the db
resource "google_compute_instance" "instance_with_ip_db" {
    name         = "db-vm"
    machine_type = "f1-micro"
    zone         = "${var.zone}"
    tags         = ["http-server"]

    boot_disk {
        initialize_params{
            image = "cos-cloud/cos-stable"
        }
    }

    metadata = {
        ssh-keys = "${var.ssh_username}:${file(var.ssh_pub_key_path)}"
        gce-container-declaration = "spec:\n  containers:\n    - name: db-vm\n      image: 'gcr.io/course-project-264412/db-users:1'\n      stdin: false\n      tty: false\n  restartPolicy: Always\n"
    }    
    
    network_interface {
        network = "default"
        access_config {
           // nat_ip = "${google_compute_address.static_db.address}"
        }
    }
}

// Expose IP of VM

//output "ip_db" {
 //value = "${google_compute_instance.instance_with_ip_db.network_interface.0.access_config.0.nat_ip}"
//}