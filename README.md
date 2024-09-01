# Basic-Secure: Comprehensive Server Security Setup

This guide provides detailed steps to set up a secure server environment with firewall rules, monitoring tools, and automated scripts.

If you want to automate the entire process, you can use the `runsecure.sh` script. To do this, follow these steps:

1. Give the script the correct permissions:
   ```bash
   chmod +x runsecure.sh
   ```

2. Run the script with sudo privileges:
   ```bash
   sudo ./runsecure.sh
   ```

This script will automate the setup process, guiding you through each step and applying the security measures outlined in this guide. Remember to review the script's actions and ensure they align with your specific server requirements before running it.

For those who prefer a manual approach or want to understand each step, continue with the detailed guide below.

## 1. Configure Firewall

UFW (Uncomplicated Firewall) is a user-friendly interface for managing iptables. Here's how to set it up:

- Enable UFW:
  ```bash
  sudo ufw enable
  ```
  Note: This may disconnect your SSH session if you haven't set up the SSH rule yet.

- Allow necessary ports:
  ```bash
  sudo ufw allow ssh
  sudo ufw allow 80/tcp  # HTTP
  sudo ufw allow 443/tcp # HTTPS
  sudo ufw allow 9090/tcp # Prometheus
  sudo ufw allow 3000/tcp # Grafana
  sudo ufw allow 9100/tcp # Node Exporter
  ```

- Limit SSH access to prevent brute-force attacks:
  ```bash
  sudo ufw limit ssh/tcp
  ```

- Check UFW status:
  ```bash
  sudo ufw status verbose
  ```

## 2. Setup Daily Maintenance Script

To set up a script for daily maintenance tasks:

- Move the existing script to the correct directory:
  ```bash
  sudo mv daily_maintenance.sh /usr/local/bin/
  ```

- Set proper permissions:
  ```bash
  sudo chmod +x /usr/local/bin/daily_maintenance.sh
  ```

- Configure a cron job to run the script daily:
  ```bash
  sudo crontab -e
  ```
  Add the following line to run the script every day at 2:00 AM:
  ```
  0 2 * * * /usr/local/bin/daily_maintenance.sh
  ```

This script should include tasks such as updating packages, cleaning up unnecessary files, updating virus definitions, and running security scans. Ensure that the script contains all necessary maintenance tasks for your specific server setup.

## 3. Install Security Tools

### AIDE (Advanced Intrusion Detection Environment)

AIDE helps detect unauthorized changes to files:

```bash
sudo apt install aide
sudo aideinit
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

### RKHunter (Rootkit Hunter)

RKHunter scans for rootkits, backdoors, and local exploits:

```bash
sudo apt install rkhunter
sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check
```

### libpam-pwquality

This library checks password strength:

```bash
sudo apt install libpam-pwquality
sudo nano /etc/pam.d/common-password
```

Add or modify the following line:
```
password        requisite                       pam_pwquality.so retry=3 minlen=14 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
```

### ClamAV (Antivirus software)

ClamAV is an open-source antivirus engine:

```bash
sudo apt install clamav clamav-daemon
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam
```

### AppArmor (Mandatory Access Control)

AppArmor confines programs to a limited set of resources:

```bash
sudo apt install apparmor apparmor-utils
sudo aa-enforce /etc/apparmor.d/*
```

### Lynis (Security auditing tool)

Lynis performs security audits:

```bash
sudo apt install lynis
sudo lynis audit system
```

## 4. Install Monitoring Tools

### Prometheus

Prometheus is a monitoring system and time series database. To set it up:

1. Download and extract Prometheus:
   ```bash
   wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
   tar xvf prometheus-2.37.0.linux-amd64.tar.gz
   sudo mv prometheus-2.37.0.linux-amd64 /opt/prometheus
   ```

2. Create a Prometheus user:
   ```bash
   sudo useradd --no-create-home --shell /bin/false prometheus
   sudo chown -R prometheus:prometheus /opt/prometheus
   ```

3. Move the Prometheus service file to the correct location:
   ```bash
   sudo mv prometheus.service /etc/systemd/system/prometheus.service
   ```

4. Start Prometheus:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start prometheus
   sudo systemctl enable prometheus
   ```

5. Verify that Prometheus is running:
   ```bash
   sudo systemctl status prometheus
   ```

Ensure that the `prometheus.service` file contains the correct configuration for your setup, including the proper paths and any additional flags you may need.

### Grafana

Grafana is an observability platform:

```bash
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

### Node Exporter

Node Exporter provides hardware and OS metrics. To set it up:

1. Download and extract Node Exporter:
   ```bash
   wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
   tar xvf node_exporter-1.3.1.linux-amd64.tar.gz
   sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
   ```

2. Create a Node Exporter user:
   ```bash
   sudo useradd --no-create-home --shell /bin/false node_exporter
   sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
   ```

3. Move the Node Exporter service file to the correct location:
   ```bash
   sudo mv node_exporter.service /etc/systemd/system/node_exporter.service
   ```

4. Start Node Exporter:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start node_exporter
   sudo systemctl enable node_exporter
   ```

5. Verify that Node Exporter is running:
   ```bash
   sudo systemctl status node_exporter
   ```

Ensure that the `node_exporter.service` file contains the correct configuration for your setup, including the proper user, group, and ExecStart path.

## 5. Schedule Regular Security Checks

To set up regular security checks using Lynis:

1. Move the Lynis hourly check script to the correct location:
   ```bash
   sudo mv lynis_hour.sh /usr/local/bin/lynis_hour.sh
   ```

2. Set proper permissions:
   ```bash
   sudo chmod +x /usr/local/bin/lynis_hour.sh
   ```

3. Configure a cron job to run the script hourly:
   ```bash
   sudo crontab -e
   ```
   Add the following line:
   ```
   0 * * * * /usr/local/bin/lynis_hour.sh
   ```

This script will run Lynis hourly and log any warnings or suggestions. Ensure that the `lynis_hour.sh` script contains the necessary commands to run Lynis and process its output as required for your security monitoring needs.

Alternatively, you can use the following script for more detailed hourly checks:

```bash
#!/bin/bash

sudo lynis audit system --cronjob > /var/log/lynis_hourly.log 2>&1

if grep -q "Warning:" /var/log/lynis_hourly.log || grep -q "Suggestion:" /var/log/lynis_hourly.log; then
    echo "Lynis found warnings or suggestions. Please check /var/log/lynis_hourly.log for details." | mail -s "Lynis Hourly Check Alert" root@localhost
fi
```

## Conclusion

This guide provides a comprehensive approach to securing your server. However, security is an ongoing process. Regularly update your system, review logs, and stay informed about the latest security best practices and vulnerabilities.

Remember to:
- Keep your system and installed packages up-to-date
- Regularly review and adjust firewall rules
- Monitor system logs for suspicious activities
- Perform regular security audits
- Keep backups of your important data
- Stay informed about security vulnerabilities related to the software you use

By following these practices and continuously improving your security measures, you can maintain a robust security posture for your server.
