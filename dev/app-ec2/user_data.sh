#!/bin/bash

apt-get update -y
apt-get install -y wget git
curl -sSl https://get.docker.com/ | bash -s
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
mkdir -p /usr/share/collectd/
touch /usr/share/collectd/types.db

cat << EOF >> /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "root"
	},
	"metrics": {
		"metrics_collected": {
			"collectd": {
				"metrics_aggregation_interval": 60
			},
			"disk": {
				"measurement": [
					"used_percent"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			}
		}
	}
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

usermod -aG docker ubuntu

su ubuntu
cd /home/ubuntu
git clone https://github.com/jaumzors/static-webpages-test
cd static-webpages-test
docker run -d -p ${app_external_port}:80 --restart always -v /home/ubuntu/static-webpages-test:/usr/share/nginx/html:ro nginx