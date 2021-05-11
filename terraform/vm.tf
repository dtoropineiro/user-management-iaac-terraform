resource "google_compute_address" "static_app" {
  name = "ipv4-address-app"
}

resource "google_compute_firewall" "default" {
 name    = "drone-firewall"
 network = "default"

 allow {
   protocol = "icmp"
 }

 allow {
   protocol = "tcp"
   ports    = ["80", "5432", "8000", "8080", "9000"]
 }
 source_ranges = ["0.0.0.0/0"]
 source_tags = ["web"]

}

// VM with the app
resource "google_compute_instance" "instance_with_ip" {
    name         = "user-management-vm"
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
        gce-container-declaration = "spec:\n  containers:\n    - name: user-management-vm\n      image: 'gcr.io/course-project-264412/user-management:1'\n      stdin: false\n      tty: false\n  restartPolicy: Always\n"
    }    

    network_interface {
        network = "default"
        access_config {
            //nat_ip = "${google_compute_address.static_app.address}"
        }
    }
}

// Expose IP of VM
//output "ip" {
// value = "${google_compute_instance.instance_with_ip.network_interface.0.access_config.0.nat_ip}"
//}
