# Terraform Cloud VCS Integration Checklist

Track your progress through the setup using this checklist.

## Terraform Cloud Setup
- [ ] Create organization in Terraform Cloud
- [ ] Create workspace with VCS-driven workflow selected
- [ ] Connect GitHub via OAuth (authorize Terraform Cloud)
- [ ] Select your GitHub repository
- [ ] Add AWS_ACCESS_KEY_ID environment variable (sensitive)
- [ ] Add AWS_SECRET_ACCESS_KEY environment variable (sensitive)
- [ ] Add AWS_REGION environment variable
- [ ] Add TF_VAR_db_password Terraform variable (sensitive)
- [ ] Add TF_VAR_jwt_secret Terraform variable (sensitive)
- [ ] Add any other required TF_VAR_* variables

## GitHub Setup
- [ ] Verify webhook created (Settings → Webhooks)
- [ ] Create branch protection rule for `main`
- [ ] Enable "Require pull request before merging"
- [ ] Enable "Require status checks to pass"
- [ ] Select Terraform Cloud status check
- [ ] Enable "Require branches to be up to date" (optional)
- [ ] Verify Terraform Cloud configured to apply on `main` branch

## Testing
- [ ] Create feature branch and push
- [ ] Open PR and verify Terraform Cloud runs plan
- [ ] Review plan in PR comments
- [ ] Merge PR to `main`
- [ ] Verify Terraform Cloud runs apply
- [ ] Confirm apply completes successfully
- [ ] Delete test branch

## Documentation
- [ ] Read TERRAFORM_CLOUD_SETUP.md fully
- [ ] Document any team-specific approval workflows
- [ ] Share workspace access with team members (if needed)
- [ ] Update team runbook with new workflow

## Security
- [ ] Verify AWS credentials are rotated periodically
- [ ] Confirm sensitive variables are marked as sensitive
- [ ] Review team/member access in Terraform Cloud
- [ ] Enable audit logging (if available in your TF Cloud plan)

## Post-Setup
- [ ] Remove temporary test files/branches
- [ ] Configure cost estimates (optional)
- [ ] Set up email notifications for run failures (optional)
- [ ] Schedule team training on new workflow
