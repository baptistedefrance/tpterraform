variable "ami_id" {
  description = "AMI ID de l'image fonctionnelle du TP1"
  type        = string
  default     = "ami-06399e63ed77119e2"  # Ajoutez votre ID AMI ici
}


variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "asg_min_size" {
  description = "Nombre minimum d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Nombre maximum d'instances dans l'Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Capacité désirée de l'Auto Scaling Group"
  type        = number
  default     = 3
}

variable "trigram" {
  description = "BDE"
  type        = string
}
