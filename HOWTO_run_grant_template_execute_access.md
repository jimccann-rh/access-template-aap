# How To Run `grant_template_execute_access.yml` Directly

This guide shows how to run the playbook without using:

- `playbooks/grant_template_execute_access.sh`

## 1) Go to the repo root

```bash
cd /home/jimccann/tempy
```

## 2) Set controller connection/auth variables

Token-based auth (recommended):

```bash
export AAP_URL="https://aap.com"
export AAP_TOKEN="your-token"
export AAP_VERIFY_SSL=true
```

Username/password auth (alternative):

```bash
export AAP_URL="https://aap.com"
export AAP_USERNAME="your-user"
export AAP_PASSWORD="your-pass"
export AAP_VERIFY_SSL=true
unset AAP_TOKEN
```

## 3) Run for one template

```bash
ansible-playbook playbooks/grant_template_execute_access.yml \
  -e "template_name=vSphere-Nested-DEVQE-static" \
  -e "username=datucker"
```

## 4) Run for multiple templates

```bash
ansible-playbook playbooks/grant_template_execute_access.yml \
  -e "template_names=vSphere-Nested-DEVQE,vSphere-Nested-DEVQE-static" \
  -e "username=datucker"
```

## Notes

- Run commands from `/home/jimccann/tempy` so `ansible.cfg`, `inventory.yml`, and `group_vars/` are loaded.
- `-e` values override environment defaults.
- `template_names` accepts a comma-separated string or a list.
