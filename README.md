# Simple-Secure: Comprehensive Server Security Setup Guide

This guide provides detailed steps to set up a secure server environment with firewall rules, monitoring tools, and automated scripts.

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

Create a script to perform daily maintenance tasks:

- Create the script:
  ```bash
  sudo nano /usr/local/bin/daily_maintenance.sh
  ```

- Add the following content:
  ```bash
  #!/bin/bash
  
  # Update package list
  apt update
  
  # Upgrade packages
  apt upgrade -y
  
  # Remove unnecessary packages
  apt autoremove -y
  
  # Clean apt cache
  apt clean
  
  # Update ClamAV virus definitions
  freshclam
  
  # Run a quick system scan with ClamAV
  clamscan -r /home
  
  # Update rkhunter database
  rkhunter --update
  
  # Run rkhunter check
  rkhunter --check --skip-keypress
  ```

- Set proper permissions:
  ```bash
  sudo chmod +x /usr/local/bin/daily_maintenance.sh
  ```

- Configure cron job to run daily:
  ```bash
  sudo crontab -e
  ```
  Add the following line:
  ```
  0 2 * * * /usr/local/bin/daily_maintenance.sh
  ```
  This will run the script every day at 2:00 AM.

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

Prometheus is a monitoring system and time series database:

```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
tar xvf prometheus-2.37.0.linux-amd64.tar.gz
sudo mv prometheus-2.37.0.linux-amd64 /opt/prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /opt/prometheus
```

Create a systemd service file:
```bash
sudo nano /etc/systemd/system/prometheus.service
```

Add the following content:
```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
    --config.file /opt/prometheus/prometheus.yml \
    --storage.tsdb.path /opt/prometheus/data \
    --web.console.templates=/opt/prometheus/consoles \
    --web.console.libraries=/opt/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

Start Prometheus:
```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

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

Node Exporter provides hardware and OS metrics:

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvf node_exporter-1.3.1.linux-amd64.tar.gz
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

Create a systemd service file:
```bash
sudo nano /etc/systemd/system/node_exporter.service
```

Add the following content:
```
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

Start Node Exporter:
```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

## 5. Schedule Regular Security Checks

Create a script for hourly Lynis checks:

```bash
sudo nano /usr/local/bin/lynis_hourly_check.sh
```

Add the following content:
```bash
#!/bin/bash

# Run Lynis audit
sudo lynis audit system --cronjob > /var/log/lynis_hourly.log 2>&1

# Check for specific strings in the log
if grep -q "Warning:" /var/log/lynis_hourly.log || grep -q "Suggestion:" /var/log/lynis_hourly.log; then
    echo "Lynis found warnings or suggestions. Please check /var/log/lynis_hourly.log for details." | mail -s "Lynis Hourly Check Alert" root@localhost
fi
```

Set proper permissions:
```bash
sudo chmod +x /usr/local/bin/lynis_hourly_check.sh
```

Configure cron job to run hourly:
```bash
sudo crontab -e
```
Add the following line:
```
0 * * * * /usr/local/bin/lynis_hourly_check.sh
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
