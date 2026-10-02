output "namespace" {
  value = kubernetes_namespace.kong.metadata[0].name
}

output "release_name" {
  value = helm_release.kong.name
}
