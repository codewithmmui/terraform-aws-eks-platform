# GitHub OIDC

Create the provider once per AWS account, then a plan/apply role per environment. Configure GitHub Environment variables `AWS_REGION`, `AWS_PLAN_ROLE_ARN`, `AWS_APPLY_ROLE_ARN`, and backend/input settings. The workflow requests `id-token: write`; `configure-aws-credentials` exchanges that token for a short STS session. No AWS access key is stored.

Restrict `sub` to repository branches for plan and `repo:ORG/REPO:environment:prod` for production apply. The generic module begins repository-scoped and should be narrowed in an organizational wrapper. GitHub Environment approval is an additional control, not a replacement for IAM. Diagnose failures by checking the token audience/subject, provider URL, trust condition, role ARN, branch/environment, and CloudTrail `AssumeRoleWithWebIdentity` event.
