resource "aws_s3_bucket" "zuedev-opentofu-state" {
  bucket = "zuedev-opentofu-state"
}

resource "aws_s3_bucket_versioning" "zuedev-opentofu-state" {
  bucket = aws_s3_bucket.zuedev-opentofu-state.id
  versioning_configuration {
    status = "Enabled"
  }
}