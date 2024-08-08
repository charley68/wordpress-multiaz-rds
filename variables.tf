variable "region" {
    type        = string
}

variable "availability_zone" {
  type    = list(string)
}

variable "project" {
    type = string
}

variable "instance" {
    type = string
}

variable "script_path" {
  type = string
}

variable "db_engine" {
    type = string
}
             
variable "db_engine_version" {
    type = string
}

variable "db_name" {
    type = string
}
                     
variable "db_username" {
  type = string
}
          
variable "db_password" {
    type = string
} 

//variable "wordpress_docker_image" {
//   type = string
//}

variable "s3_bucket_name" {
    type = string
}
