#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "Welcome to RunSecure: Automated Server Security Setup Script"
echo "This script will guide you through the process of securing your server."
echo "Some steps may require manual intervention."
echo

confirm() {
    read -p "$1 (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

configure_firewall() {
    echo "Configuring UFW (Uncomplicated Firewall)..."
    apt-get install ufw -y
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 9090/tcp
    ufw allow 3000/tcp
    ufw allow 9100/tcp
    ufw limit ssh/tcp
    echo "y" | ufw enable
    ufw status verbose
}

setup_maintenance_script() {
    echo "Setting up daily maintenance script..."
    cat > /usr/local/bin/daily_maintenance.sh << EOL
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean
freshclam
rkhunter --update
rkhunter --check --skip-keypress
lynis audit system
EOL
    chmod +x /usr/local/bin/daily_maintenance.sh
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/daily_maintenance.sh") | crontab -
}

install_security_tools() {
    echo "Installing security tools..."
    apt-get update
    apt-get install -y aide rkhunter libpam-pwquality clamav clamav-daemon apparmor apparmor-utils lynis

    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

    rkhunter --update
    rkhunter --propupd

    systemctl stop clamav-freshclam
    freshclam
    systemctl start clamav-freshclam

    aa-enforce /etc/apparmor.d/*

    echo "Configuring libpam-pwquality..."
    sed -i '/pam_pwquality.so/c\password        requisite                       pam_pwquality.so retry=3 minlen=14 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1' /etc/pam.d/common-password
}

install_monitoring_tools() {
    echo "Installing Prometheus..."
    wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
    tar xvf prometheus-2.37.0.linux-amd64.tar.gz
    mv prometheus-2.37.0.linux-amd64 /opt/prometheus
    useradd --no-create-home --shell /bin/false prometheus
    chown -R prometheus:prometheus /opt/prometheus

    cat > /etc/systemd/system/prometheus.service << EOL
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
EOL

    systemctl daemon-reload
    systemctl start prometheus
    systemctl enable prometheus

    echo "Installing Grafana..."
    apt-get install -y software-properties-common
    add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
    apt-get update
    apt-get install -y grafana
    systemctl start grafana-server
    systemctl enable grafana-server

    echo "Installing Node Exporter..."
    wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
    tar xvf node_exporter-1.3.1.linux-amd64.tar.gz
    mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
    useradd --no-create-home --shell /bin/false node_exporter
    chown node_exporter:node_exporter /usr/local/bin/node_exporter

    cat > /etc/systemd/system/node_exporter.service << EOL
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
EOL

    systemctl daemon-reload
    systemctl start node_exporter
    systemctl enable node_exporter
}

setup_security_checks() {
    echo "Setting up regular security checks..."
    cat > /usr/local/bin/lynis_hour.sh << EOL
#!/bin/bash
lynis audit system --cronjob > /var/log/lynis_hourly.log 2>&1
if grep -q "Warning:" /var/log/lynis_hourly.log || grep -q "Suggestion:" /var/log/lynis_hourly.log; then
    echo "Lynis found warnings or suggestions. Please check /var/log/lynis_hourly.log for details." | mail -s "Lynis Hourly Check Alert" root@localhost
fi
EOL
    chmod +x /usr/local/bin/lynis_hour.sh
    (crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/lynis_hour.sh") | crontab -
}

if confirm "Do you want to configure the firewall?"; then
    configure_firewall
fi

if confirm "Do you want to set up the daily maintenance script?"; then
    setup_maintenance_script
fi

if confirm "Do you want to install security tools?"; then
    install_security_tools
fi

if confirm "Do you want to install monitoring tools?"; then
    install_monitoring_tools
fi

if confirm "Do you want to set up regular security checks?"; then
    setup_security_checks
fi

echo "Server security setup complete!"
echo "Please review the changes and ensure everything is working as expected."
echo "Remember to regularly update your system and stay informed about security best practices."

