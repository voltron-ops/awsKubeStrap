output "master-node-dns" {
    value = aws_instance.master-node.public_dns
}

output "worker-node01-dns" {
    value = aws_instance.worker-node01.public_dns
}

output "worker-node02-dns" {
    value = aws_instance.worker-node02.public_dns
}