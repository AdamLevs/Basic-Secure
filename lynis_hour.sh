#!/bin/bash

# Run Lynis
lynis audit system > /tmp/lynis_report.txt

# Adjust parsing based on Lynis output
grep "Some Metric" /tmp/lynis_report.txt | awk '{print "lynis_metric{"metric"="'$2'"} " $3}' > /tmp/metrics.prom

# Push to Prometheus
curl -X POST --data-binary @/tmp/metrics.prom http://localhost:9091/metrics/job/lynis

