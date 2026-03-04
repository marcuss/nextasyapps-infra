module "nextasy_website" {
  source = "../../modules/s3-spa"

  bucket_name = "nextasy-co-website"
  environment = "dev"

  tags = {
    App  = "nextasy-web"
    Team = "nextasy"
  }
}
