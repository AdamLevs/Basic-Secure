# Simple-Secure: Server Security Setup Guide

This guide outlines key steps to set up a secure server environment with firewall rules, monitoring tools, and automated scripts.

## 1. Configure Firewall

- Enable UFW (Uncomplicated Firewall):
  ```bash
  sudo ufw enable
  ```
- Allow necessary ports (e.g., SSH, HTTP, HTTPS):
  ```bash
  sudo ufw allow ssh
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  ```
- Limit SSH access:
  ```bash
  sudo ufw limit ssh/tcp
  ```

## 2. Setup Daily Maintenance Script

- Move script to `/usr/local/bin` and set permissions
- Configure cron job to run daily

## 3. Install Security Tools

- AIDE (Advanced Intrusion Detection Environment)
- RKHunter (Rootkit Hunter)
- libpam-pwquality (Password quality checking library)
- ClamAV (Antivirus software)
- AppArmor (Mandatory Access Control)
- Lynis (Security auditing tool)

## 4. Install Monitoring Tools

- Prometheus (Monitoring system & time series database)
- Grafana (Observability platform)
- Node Exporter (Hardware and OS metrics exporter)

## 5. Schedule Regular Security Checks

- Configure hourly Lynis checks via cron job

## Conclusion

Regularly update your system and review security practices to maintain a robust security posture.
