# Permissions policies (WHAT each role can do), written with
# aws_iam_policy_document so Terraform validates the structure for you.

# ---------------------------------------------------------------- Developer
data "aws_iam_policy_document" "developer" {
  statement {
    sid       = "DescribeEC2"
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid       = "StartStopOnlyDevTaggedInstances"
    effect    = "Allow"
    actions   = ["ec2:StartInstances", "ec2:StopInstances"]
    resources = ["arn:${local.partition}:ec2:*:${local.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = ["Dev"]
    }
  }

  statement {
    sid       = "ReadS3"
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets", "s3:ListBucket", "s3:GetObject"]
    resources = ["*"]
  }
}

# ------------------------------------------------------------- DataAnalyst
data "aws_iam_policy_document" "data_analyst" {
  statement {
    sid     = "ListDataBuckets"
    effect  = "Allow"
    actions = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [
      aws_s3_bucket.lab["analytics_data"].arn,
      aws_s3_bucket.lab["athena_results"].arn,
    ]
  }

  statement {
    sid       = "ReadAnalyticsData"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.lab["analytics_data"].arn}/*"]
  }

  statement {
    sid       = "ReadWriteAthenaResults"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:AbortMultipartUpload"]
    resources = ["${aws_s3_bucket.lab["athena_results"].arn}/*"]
  }

  statement {
    sid    = "RunAthenaQueries"
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:BatchGetQueryExecution",
      "athena:ListQueryExecutions",
      "athena:GetWorkGroup",
      "athena:ListWorkGroups",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadGlueCatalog"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
    ]
    resources = ["*"]
  }
}

# -------------------------------------------------------------- MLEngineer
data "aws_iam_policy_document" "ml_engineer" {
  statement {
    sid    = "ManageSageMakerWorkloads"
    effect = "Allow"
    actions = [
      "sagemaker:CreateTrainingJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:ListTrainingJobs",
      "sagemaker:StopTrainingJob",
      "sagemaker:CreateProcessingJob",
      "sagemaker:DescribeProcessingJob",
      "sagemaker:ListProcessingJobs",
      "sagemaker:CreateModel",
      "sagemaker:DescribeModel",
      "sagemaker:ListModels",
      "sagemaker:DeleteModel",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:ListEndpointConfigs",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:CreateEndpoint",
      "sagemaker:DescribeEndpoint",
      "sagemaker:ListEndpoints",
      "sagemaker:DeleteEndpoint",
      "sagemaker:InvokeEndpoint",
      "sagemaker:CreateNotebookInstance",
      "sagemaker:DescribeNotebookInstance",
      "sagemaker:ListNotebookInstances",
      "sagemaker:StartNotebookInstance",
      "sagemaker:StopNotebookInstance",
      "sagemaker:CreatePresignedNotebookInstanceUrl",
      "sagemaker:AddTags",
      "sagemaker:ListTags",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ListMlBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.lab["ml_artifacts"].arn]
  }

  statement {
    sid       = "ReadWriteMlArtifacts"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.lab["ml_artifacts"].arn}/*"]
  }

  statement {
    sid    = "PullTrainingImages"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRepositories",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadSageMakerLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
    resources = ["arn:${local.partition}:logs:*:${local.account_id}:log-group:/aws/sagemaker/*"]
  }

  statement {
    sid       = "ReadMetrics"
    effect    = "Allow"
    actions   = ["cloudwatch:GetMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics"]
    resources = ["*"]
  }

  # Hand a SageMaker execution role to jobs, but only to SageMaker,
  # and only roles named SageMakerExecution-*.
  statement {
    sid       = "PassExecutionRoleToSageMaker"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:${local.partition}:iam::${local.account_id}:role/SageMakerExecution-*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["sagemaker.amazonaws.com"]
    }
  }
}
