terraform {
 backend "s3" {
   bucket         = "tf-s3-backend-7887"
   key            = "state/terraform.tfstate"
   region         = "us-west-1"
   encrypt        = true
   kms_key_id     = "alias/terraform-bucket-key"
   dynamodb_table = "terraform-state"
 }
}
