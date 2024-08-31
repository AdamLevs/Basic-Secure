Simple-Secure
Introduction
This guide will help you set up a secure server environment with firewall rules, monitoring tools, and automated scripts.

1. Configure Firewall
To enable the firewall, use the following command:

bash
Copy code
sudo ufw enable
Note: Enabling the firewall may disconnect your remote SSH session.

To allow SSH and additional ports for various applications, run:

bash
Copy code
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 9090/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 9100/tcp
To allow any specific port, use:

bash
Copy code
sudo ufw allow <port_number>
To limit SSH access, you can use:

bash
Copy code
sudo ufw limit ssh/tcp
2. Setup Daily Maintenance Script
Move the daily maintenance script and set the correct permissions:

bash
Copy code
sudo mv daily_maintenance.sh /usr/local/bin
sudo chmod +x /usr/local/bin/daily_maintenance.sh
To run this script automatically, configure a cron job:

bash
Copy code
sudo crontab -e
Add the following line to execute the script daily at midnight (00:00):

bash
Copy code
0 0 * * * /usr/local/bin/daily_maintenance.sh
3. Install Security Tools
Install AIDE:

bash
Copy code
sudo apt install aide
sudo aideinit
Install RKHunter:

bash
Copy code
sudo apt install rkhunter
sudo rkhunter --update
sudo rkhunter --check
Install libpam-pwquality:

bash
Copy code
sudo apt install libpam-pwquality
Install ClamAV:

bash
Copy code
sudo apt install clamav clamav-daemon
sudo systemctl status clamav-freshclam
sudo systemctl enable clamav-freshclam
sudo systemctl start clamav-freshclam
Install AppArmor:

bash
Copy code
sudo apt install apparmor
Install Lynis:

bash
Copy code
sudo apt install lynis
sudo lynis audit system
4. Install Monitoring Tools
Install Prometheus:

bash
Copy code
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
tar xvf prometheus-2.43.0.linux-amd64.tar.gz
sudo mv prometheus-2.43.0.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-2.43.0.linux-amd64/promtool /usr/local/bin/
sudo mkdir /etc/prometheus
sudo mv prometheus-2.43.0.linux-amd64/prometheus.yml /etc/prometheus/
sudo mv prometheus-2.43.0.linux-amd64/consoles /etc/prometheus/
sudo mv prometheus-2.43.0.linux-amd64/console_libraries /etc/prometheus/
Create a Prometheus service:

bash
Copy code
sudo cp prometheus.service /etc/systemd/system/prometheus.service
Create a Prometheus user and set permissions:

bash
Copy code
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
Start the Prometheus service:

bash
Copy code
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
Install Grafana:

bash
Copy code
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
Install Node Exporter:

bash
Copy code
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/
sudo cp node_exporter.service /etc/systemd/system
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
Configure Prometheus:

bash
Copy code
sudo cp prometheus.yaml /etc/prometheus/prometheus.yml
sudo systemctl restart prometheus
Verify targets at http://localhost:9090. After setting up targets (Node Exporter and Lynis), access Grafana at http://localhost:3000. The default login is admin for both username and password, which you should change immediately. Add Prometheus as a data source and create dashboards as needed.

5. Schedule Lynis Checks
Copy the Lynis hourly check script and set permissions:

bash
Copy code
sudo cp lynis_hour.sh /usr/local/bin/lynis_hour.sh
sudo chmod +x /usr/local/bin/lynis_hour.sh
Configure a cron job to run the script every hour:

bash
Copy code
sudo crontab -e
Add the following line:

bash
Copy code
0 * * * * /usr/local/bin/lynis_hour.sh
Conclusion
Your server is now more secure with monitoring and maintenance tools in place. Remember, while these steps enhance security, no system is entirely immune to threats. Regularly check for updates and best practices to maintain security.

This cleaned-up version resolves all conflict markers and retains all the useful information.
