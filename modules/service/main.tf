variable "apigee_environment" {}
variable "name" {}
variable "path" {}
variable "proxy_type" {}


data "archive_file" "bundle" {
  type = "zip"
  source_dir = "${path.root}/releases/${var.name}/proxies/${var.proxy_type}"
  output_path = "${path.root}/proxies/${var.name}.zip"
}

resource "apigee_api_proxy" "proxy" {
  name = "${var.name}-${var.apigee_environment}"
  bundle = data.archive_file.bundle.output_path
  bundle_sha = data.archive_file.bundle.output_sha
}

resource "apigee_api_proxy_deployment" "proxy_deployment" {
  proxy_name = apigee_api_proxy.proxy.name
  env = var.apigee_environment
  revision = apigee_api_proxy.proxy.revision
  override = true
  delay = 60
}

resource "apigee_product" "product" {
  name = "${var.name}-${var.apigee_environment}"
  approval_type = "auto"
  proxies = [apigee_api_proxy.proxy.name]

  attributes = {
    access = "public"
  }
  environments = [var.apigee_environment]
}
