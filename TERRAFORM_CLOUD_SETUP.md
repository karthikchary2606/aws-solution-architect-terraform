# Terraform Cloud VCS Integration Setup Guide

This guide walks you through connecting your GitHub repository to Terraform Cloud for VCS-driven runs.

## Prerequisites
- Terraform Cloud account (free tier available at https://app.terraform.io)
- GitHub account with admin access to the repository
- AWS credentials (Access Key ID and Secret Access Key)

---

## Part 1: Terraform Cloud Setup

### Step 1: Create or Access Your Organization
1. Log in to [Terraform Cloud](https://app.terraform.io)
2. Click **Organizations** in the top nav
3. Click **Create Organization** (or skip if you already have one)
4. Name: `your-org-name` (e.g., `karthik-tf`)
5. Email: Your email address
6. Click **Create**

### Step 2: Create a Workspace
1. In your organization, click **Workspaces**
2. Click **New Workspace**
3. **Workspace name:** `aws-solution-architect` (or your preferred name)
4. **Workspace type:** Choose **VCS-driven run workflow** (important!)
5. Click **Create Workspace**

### Step 3: Connect GitHub via OAuth
1. You'll be prompted to **Connect VCS Provider**
2. Click **GitHub** (or the relevant provider)
3. Click **Connect & Continue**
4. You'll be redirected to GitHub to authorize Terraform Cloud
   - Click **Authorize hashicorp** on the GitHub authorization screen
5. After authorization, you'll return to Terraform Cloud

### Step 4: Select Your Repository
1. In the **Repository** section, search for your repo: `aws-solution-architect-terraform`
2. Select it from the dropdown
3. Click **Create Workspace**

### Step 5: Configure Variables
Once the workspace is created, add AWS credentials:

1. Go to **Workspace Settings** → **Variables**
2. Click **Add Variable** for each:

   | Name | Type | Sensitive | Value |
   |------|------|-----------|-------|
   | `AWS_ACCESS_KEY_ID` | Environment | ✓ | Your AWS access key |
   | `AWS_SECRET_ACCESS_KEY` | Environment | ✓ | Your AWS secret key |
   | `AWS_REGION` | Environment | - | `us-east-1` |
   | `TF_VAR_db_password` | Terraform | ✓ | Your RDS password |
   | `TF_VAR_jwt_secret` | Terraform | ✓ | Your JWT secret |

3. Add any other `TF_VAR_*` variables you need as Terraform variables

**Note:** Environment variables (AWS_*) are injected into the shell. Terraform variables (TF_VAR_*) override your `.tf` files.

---

## Part 2: GitHub Setup

### Step 1: Verify Webhook (Auto-Created)
1. Go to your GitHub repo
2. Settings → **Webhooks**
3. You should see a webhook from `app.terraform.io`
4. If not present, Terraform Cloud will create it

### Step 2: Configure Branch Protection Rules
1. Go to your GitHub repo
2. Settings → **Branches**
3. Click **Add rule** next to **Branch protection rules**
4. Apply to: `main`
5. Enable:
   - ✓ **Require a pull request before merging**
   - ✓ **Require status checks to pass before merging**
   - ✓ Find and select `Terraform Cloud / aws-solution-architect` status check
   - ✓ **Require branches to be up to date before merging** (optional but recommended)
6. Click **Create**

### Step 3: Designate Main as Apply Branch (in Terraform Cloud)
1. Go back to Terraform Cloud
2. Workspace → **Settings** → **Version Control**
3. **VCS Branch:** Leave empty (watches all branches)
4. **Automatic Run Trigger:** Set to `main` (this is where applies happen)
5. Save

---

## Part 3: Test the Integration

### Test 1: Create a Feature Branch and Open a PR
```bash
git checkout -b test/terraform-cloud
# Make a small change to any .tf file, or just add a comment
git commit -am "test: terraform cloud integration"
git push -u origin test/terraform-cloud
```

Then:
1. Open a PR on GitHub for this branch
2. Go to Terraform Cloud → Workspace
3. You should see a **Queued** run
4. Wait for the plan to complete (~30-60 seconds)
5. Check the PR comments — Terraform Cloud will post the plan output

### Test 2: Merge to Main and Trigger Apply
1. Merge the PR to `main` (if the plan succeeded)
2. Go to Terraform Cloud
3. You should see another run **Queued**
4. Once the plan completes, click **Confirm & Apply** in Terraform Cloud
5. Watch the apply progress in the UI

---

## Ongoing Workflow

### For Feature Branches:
```bash
git checkout -b feature/my-feature
# Make changes
git push -u origin feature/my-feature
# Open PR
# Terraform Cloud auto-plans
# Review the plan in the PR comments
# Push additional changes if needed (plan re-runs automatically)
```

### For Merging to Main:
```bash
# After PR approval and plan is successful
# Merge PR on GitHub
# Terraform Cloud auto-applies
```

---

## Troubleshooting

### Webhook Not Firing
- Check GitHub Webhooks (Settings → Webhooks)
- Verify Terraform Cloud webhook shows successful deliveries
- Check firewall/network policies aren't blocking `app.terraform.io`

### Plan Shows "No Changes"
- This is normal if no `.tf` files changed
- Terraform Cloud still validates configuration syntax

### Apply Fails
- Check **Workspace Settings** → **Variables** — all required variables set?
- Check AWS credentials are correct (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- Check CloudWatch Logs / CloudTrail for AWS API errors
- Click **Logs** in the Terraform Cloud run UI

### State File Issues
- Terraform Cloud manages state automatically — don't use local state files
- Remove any `terraform.tfstate` files from git (check `.gitignore`)

---

## Security Best Practices

1. **Rotate AWS credentials** every 90 days
   - Update them in Terraform Cloud Variables
2. **Use IAM role for automation** (optional, more secure)
   - Instead of long-lived access keys, consider an OIDC trust relationship
3. **Audit who has access** — Terraform Cloud Settings → Teams & Management
4. **Enable run policy** for cost limits (Workspace → Settings → Run Tasks)
5. **Use state locking** — Terraform Cloud does this automatically

---

## Helpful Commands

Check if Terraform Cloud state is being used:
```bash
terraform state list
# Should error: "Error: Initialization required"
# (meaning it's not using local state)
```

View current Terraform Cloud workspace:
```bash
grep 'cloud' terraform.tf
```

---

## Next Steps

1. After testing, remove the test branch
2. Set up team access in Terraform Cloud (optional)
3. Configure cost estimates (Workspace → Settings → Run Tasks)
4. Document any custom approval workflows in your team's runbook
