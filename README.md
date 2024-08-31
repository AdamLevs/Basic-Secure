# Simple-Secure


well first of all we want to enable the FireWall we can do that in simple command: 
Sudo ufw enable # be aware if you using remote or ssh it may disconnect you
# to allow ssh (and im allowing more port for the next apps) use
sudo ufw allow ssh 
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 9090/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 9100/tcp
# use the ufw allow for enable any port u use
# u can even use sudo ufw limit ssh/tcp to limit the ssh 

mv daily_maintenance.sh /usr/local/bin

dont forget to give the right premmissision:
sudo chmod +x /usr/local/bin/daily_maintenance.sh


after that we want the script work automatically by using cron job:
sudo crontab -e
# add this line at the end of the file
0 0 * * * /usr/local/bin/daily_maintenance.sh # right now it runinng evry day at 00:00, you can change that if you want to

# NOW LET START DOWNLOAD APPS THAT MAY HELP YOU
first lets install aide:
 
sudo apt install aide
sudo aideinit

now lets install rkhunter:
sudo apt install rkhunter
sudo rkhunter --update
# use the sudo rkhunter --check to check any logs

# now lets install the libpam-pwquality tool to enforce strong password policies and regular password changes
sudo apt install libpam-pwquality

we can install ClamAV for antivirus app:
sudo apt install clamav clamav-daemon

# after install type sudo systemctl status clamav-freshclam to see if the service running, if not:
sudo systemctl enable clamav-freshclam && sudo systemctl start clamav-freshclam

# to add more security layer we can also add the AppArmor:
sudo apt install apparmor 


The last thing we can do, is do add another monitoring app called Lynis:
sudo apt install lynis

use the command: sudo lynis audit system to check your logs, but we can add this to automaticlly see it with the grafana dashboard by using prometheus 


first of all lets install prometheus: 
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
tar xvf prometheus-2.43.0.linux-amd64.tar.gz
sudo mv prometheus-2.43.0.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-2.43.0.linux-amd64/promtool /usr/local/bin/
sudo mkdir /etc/prometheus
sudo mv prometheus-2.43.0.linux-amd64/prometheus.yml /etc/prometheus/
sudo mv prometheus-2.43.0.linux-amd64/consoles /etc/prometheus/
sudo mv prometheus-2.43.0.linux-amd64/console_libraries /etc/prometheus/

# after that we want the prometheus be as serive just cp the prometheus.service to /etc/systemd/system/prometheus.service


THEN Create Prometheus User and Set Permissions
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# after that we can start the promtheus service:
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
# to check the status:
sudo systemctl status prometheus

TO INSTALL GRAFANA: 
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana

# now tha we install we can start it by using: 
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
# check the status: 
sudo systemctl status grafana-server


INSTALL NODE_EXPORTER:
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/


for make the node a service just cp the node_exporter.service to /etc/systemd/system

Create Node Exporter User and Set Permissions

sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

AFTER THAT WE WANT TO START THE SERVICE:
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
# check the service: 
sudo systemctl status node_exporter

after all that cp the prometheus.yaml to /etc/prometheus/prometheus.yml
and restart the prometheus service by sudo systemctl restart prometheus

not we can check in http://local_host:9090 if the targets are set.
after seting the targets (node exporter and lynis) we can go to grafana web intarface, http://local_host:3000 # be aware that your first name and pss is admim, you can change it any time, after you loged in, add prometheus as data source and create dashboard as you like (in using the lynis and then i open other one in input 1860 to monitoring the system) 


now we want also the Lynis to be checked evry hour (or when ever you want)

cp the lynis_hour.sh to /usr/local/bin/lynis_hour.sh

#dont forget to give it the right premmissision: 
chmod +x /usr/local/bin/lynis_hour.sh

and again go to: sudo crontab -e and just after the last line we added, add:
0 * * * * /path/to/your/lynis_metrics_script.sh # it make the check evry hour, change it to any you like.


and that's it, now your server more secure and you can see and handle the monitoring, be aware that you dont all the step it doesnt mean your server is 100% secire, there is allways an way to get hacked, check this repository some time to check new updates.
