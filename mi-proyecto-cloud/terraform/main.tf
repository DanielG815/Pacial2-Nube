provider "google" {
  project = var.project_id
  region  = var.region
}

# Crear el Clúster de GKE
resource "google_container_cluster" "primary" {
  name     = "mi-cluster-gke"
  location = var.region
  
  # Eliminamos el pool por defecto para crear uno personalizado más barato
  remove_default_node_pool = true
  initial_node_count       = 1
}

# Crear el Grupo de Nodos (Node Pool)
resource "google_container_node_pool" "primary_nodes" {
  name       = "mi-nodo-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1  # Solo 1 nodo para el ejercicio (ahorrar costos)

  node_config {
    preemptible  = true # Más barato, ideal para pruebas
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}