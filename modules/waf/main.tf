resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "${var.name_prefix}blocked-ips"
  description        = "IP addresses that should be blocked"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ip_addresses

  tags = merge(
    {
      Name = "${var.name_prefix}blocked-ips"
    },
    var.tags
  )
}

resource "aws_wafv2_web_acl" "alb_waf" {
  name        = var.waf_name
  description = "WAF for ALB with IP blocking and common attack protection"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Règle pour bloquer tous les pays sauf ceux autorisés (si activée)
  dynamic "rule" {
    for_each = var.enable_geo_restriction ? [1] : []
    content {
      name     = "geo-block-non-allowed-countries"
      priority = 0  # Priorité la plus élevée

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            geo_match_statement {
              country_codes = var.allowed_country_codes
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoBlockNonAllowedCountries"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rule to block specific IPs
  rule {
    name     = "block-ips"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockedIPs"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Core Rule Set
  dynamic "rule" {
    for_each = var.enable_core_rule_set ? [1] : []
    content {
      name     = "AWS-AWSManagedRulesCommonRuleSet"
      priority = 2

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"

        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  # AWS Managed Rules - SQL Injection
  dynamic "rule" {
    for_each = var.enable_sql_injection_protection ? [1] : []
    content {
      name     = "AWS-AWSManagedRulesSQLiRuleSet"
      priority = 3

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesSQLiRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate-based rule to prevent DDoS
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []
    content {
      name     = "rate-limit"
      priority = 4

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimit"
        sampled_requests_enabled   = true
      }
    }
  }

  # Custom rules
  dynamic "rule" {
    for_each = var.custom_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "byte_match_statement" {
          for_each = rule.value.type == "byte_match" ? [rule.value.statement] : []
          content {
            field_to_match {
              dynamic "uri_path" {
                for_each = byte_match_statement.value.field_to_match == "uri_path" ? [1] : []
                content {}
              }
              dynamic "query_string" {
                for_each = byte_match_statement.value.field_to_match == "query_string" ? [1] : []
                content {}
              }
              dynamic "header" {
                for_each = byte_match_statement.value.field_to_match == "header" ? [1] : []
                content {
                  name = byte_match_statement.value.header_name
                }
              }
            }
            positional_constraint = byte_match_statement.value.positional_constraint
            search_string         = byte_match_statement.value.search_string
            text_transformation {
              priority = 0
              type     = byte_match_statement.value.text_transformation
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.waf_name
    sampled_requests_enabled   = true
  }

  tags = merge(
    {
      Name = var.waf_name
    },
    var.tags
  )
}

resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf.arn
}