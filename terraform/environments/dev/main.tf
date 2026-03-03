module "couplesapp_frontend" {
  source = "../../modules/s3-spa"

  bucket_name = "couplesapp-dev-frontend"
  environment = "dev"

  tags = {
    App     = "couplesapp"
    Team    = "nextasy"
  }
}
