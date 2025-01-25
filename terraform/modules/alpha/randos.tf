resource "random_shuffle" "group" {
  input = [
    for k in var.users : k
  ]
  result_count = floor(length(var.users) / 4)
  count        = floor(length(var.users) / 2)
}

resource "random_pet" "group" {
  length = 2
  count  = floor(length(var.users) / 2)
}