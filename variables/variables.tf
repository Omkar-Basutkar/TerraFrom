variable "server_port" {
                type = number
                default = 80
}

 


variable "ssh_port" {
                type = number
                default = 22
}
variable "public_cidr" {
        type = list(string)
        default = ["0.0.0.0/0"]
}


