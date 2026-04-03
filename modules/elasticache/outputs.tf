output "cluster_id" {
  description = "ElastiCache cluster ID"
  value       = aws_elasticache_cluster.main.id
}

output "cluster_address" {
  description = "ElastiCache cluster address"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "cluster_port" {
  description = "ElastiCache cluster port"
  value       = aws_elasticache_cluster.main.port
}

output "cluster_endpoint" {
  description = "ElastiCache cluster endpoint (address:port)"
  value       = "${aws_elasticache_cluster.main.cache_nodes[0].address}:${aws_elasticache_cluster.main.port}"
}

output "engine" {
  description = "Cache engine type"
  value       = aws_elasticache_cluster.main.engine
}

output "engine_version" {
  description = "Cache engine version"
  value       = aws_elasticache_cluster.main.engine_version
}

output "node_type" {
  description = "Cache node type"
  value       = aws_elasticache_cluster.main.node_type
}

output "subnet_group_name" {
  description = "ElastiCache subnet group name"
  value       = aws_elasticache_subnet_group.main.name
}
