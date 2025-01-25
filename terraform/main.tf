variable "policy" {
    type = map
    default = null
  
}


module "setup" {
  source           = "./modules/alpha"
  count =   var.policy != null ? 1 : 0
}