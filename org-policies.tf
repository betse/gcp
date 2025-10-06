# Enforce the Organization Policy to deny external IPs on VMs
resource "google_project_organization_policy" "block_public_ips" {
  project    = var.project_id
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    # Setting allow to empty and deny all to true blocks everything
    deny {
      all = true
    }
  }
}