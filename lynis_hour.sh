#!/bin/bash

# Run Lynis and save the report
lynis audit system > /tmp/lynis_report.txt

# Parse the report and extract metrics
# Adjust parsing based on Lynis output
grep "Some Metric" /tmp/lynis_report.txt | awk '{print "lynis_metric{"metric"="'$2'"} " $3}' > /tmp/metrics.prom

# Push the metrics to Prometheus Pushgateway
curl -X POST --data-binary @/tmp/metrics.prom http://localhost:9091/metrics/job/lynis

