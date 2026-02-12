# tempy - AAP Job Template Execute Access

This project contains Ansible automation to grant a user **execute** access to one or more Red Hat Ansible Automation Platform (AAP) job templates.

It uses the `awx.awx.role` module to assign the `execute` role to a target user for the specified template(s).

## What This Code Does

- Reads AAP controller connection/auth settings from env vars (or inventory/group vars).
- Accepts a single template name or multiple template names.
- Validates required inputs (`template_name`/`template_names` and `username`).
- Grants `execute` role on the target job template(s).
- Prints a summary of what was granted.

## Project Files

- `playbooks/grant_template_execute_access.yml` - Main playbook that applies role assignments.
- `playbooks/grant_template_execute_access.sh` - Convenience wrapper script around `ansible-playbook`.
- `group_vars/all.yml` - Controller variable defaults sourced from environment.
- `inventory.yml` - Localhost inventory and placeholder controller variables.
- `ansible.cfg` - Ansible defaults for this repo (inventory, YAML-style output, warning behavior).
- `requirements.yml` - Collection dependencies.
- `HOWTO_run_grant_template_execute_access.md` - Focused direct-run how-to.

## Prerequisites

- Python + `ansible-playbook` available on your machine.
- Network/API access to your AAP controller.
- A valid token (recommended) or username/password with permission to manage role assignments.
- Required collections installed:

```bash
cd /home/user
ansible-galaxy collection install -r requirements.yml
```

## Configuration

Set connection/auth values with environment variables (recommended):

```bash
export AAP_URL="https://aap.com"
export AAP_TOKEN="your-token"
export AAP_VERIFY_SSL=true
```

Alternative auth with username/password:

```bash
export AAP_URL="https://aap.com"
export AAP_USERNAME="your-user"
export AAP_PASSWORD="your-pass"
export AAP_VERIFY_SSL=true
unset AAP_TOKEN
```

## How To Run

Run from repo root so `ansible.cfg`, `inventory.yml`, and `group_vars/` are used:

```bash
cd /home/jimccann/tempy
```

### Option 1: Run Playbook Directly

Single template:

```bash
ansible-playbook playbooks/grant_template_execute_access.yml \
  -e "template_name=vSphere-Nested-DEVQE-static" \
  -e "username=datucker"
```

Multiple templates (comma-separated):

```bash
ansible-playbook playbooks/grant_template_execute_access.yml \
  -e "template_names=vSphere-Nested-DEVQE,vSphere-Nested-DEVQE-static" \
  -e "username=datucker"
```

### Option 2: Use Wrapper Script

```bash
playbooks/grant_template_execute_access.sh -t "vSphere-Nested-DEVQE-static" -u datucker
```

Multiple templates:

```bash
playbooks/grant_template_execute_access.sh -t "Template1,Template2" -u datucker
```

## Notes

- `-e` values passed on the command line override environment defaults.
- `template_names` supports comma-separated values or a YAML list.
- The repository is configured for YAML-style callback output in `ansible.cfg`.
