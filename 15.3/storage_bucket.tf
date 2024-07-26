
resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = var.storage.bucket.sa_name
}


resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = var.storage.bucket.sa_role
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}


resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}


resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.storage.bucket.bucket_name
  max_size   = var.storage.bucket.bucket_size
  acl        = var.storage.bucket.acl

  website {
    index_document = "index"
    error_document = "error"
    routing_rules  = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }

  server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = yandex_kms_symmetric_key.key-a.id
      sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "yandex_kms_symmetric_key" "key-a" {
  name              = "symetric-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" 
}

resource "yandex_storage_object" "cute-cat-picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.storage.bucket.bucket_name
  key        = "cute-cat"
  source     = "./cat.jpg"
  depends_on = [yandex_kms_symmetric_key.key-a]
}
