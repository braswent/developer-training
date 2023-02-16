output "service_name" {
  value       = google_cloud_run_service.gcr_service.name
  description = "Name of the created service"
}


output "service_url" {
    value       = google_cloud_run_service.gcr_service.status[0].url 
    description = "The URL on which the deployed service is available"
}