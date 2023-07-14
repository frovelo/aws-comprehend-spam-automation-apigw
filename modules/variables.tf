variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "trusted_role_arn" {
  type = string
}

variable "comprehend_endpoint_url" {
  type = string
}

variable "custom_classification_model_arn" {
  type = string
}

variable "custom_classification_model_name" {
  type = string
}

variable "s3_bucket_spam_path" {
  type    = string
  default = "spam"
}

variable "s3_bucket_ham_path" {
  type    = string
  default = "ham"
}

variable "s3_bucket_input_path" {
  type    = string
  default = "input"
}
variable "s3_bucket_output_path" {
  type    = string
  default = "output"
}

variable "s3_delete_objects" {
  type    = bool
  default = false
}