#!/usr/bin/env python3

import datetime
import json
import re
import os

now = datetime.datetime.now()
currentDate = now.strftime("%y-%m-%d")

cpuMetric = dict({})
with open('/proc/stat', 'r') as procfile:
	cputimes = procfile.readline()
	# /proc/stat: user, nice, system, idle, iowait, irc, softirq, steal, guest
	stat = cputimes.split(' ')[2:]
	cpuMetric['user'] = int(stat[0])
	cpuMetric['nice'] = int(stat[1])
	cpuMetric['system'] = int(stat[2])
	cpuMetric['idle'] = int(stat[3])
	cpuMetric['iowait'] = int(stat[4])
	cpuMetric['irc'] = int(stat[5])
	cpuMetric['softrq'] = int(stat[6])
	cpuMetric['steal'] = int(stat[7])
	cpuMetric['guest'] = int(stat[8])

cpuMetricsJson = json.dumps(cpuMetric)

memInfoMetric = dict({})
with open('/proc/meminfo', 'r') as procfile:
	memInfoMetric = dict(x.strip().split(None, 1) for x in procfile)
	memInfoMetric = {key.strip(':'): item.strip() for key, item in memInfoMetric.items()}

uptimeMetric = dict({})
memInfoMetricJson = json.dumps(memInfoMetric)
with open('/proc/uptime', 'r') as procfile:
	uptimeInfo = procfile.readline().split(' ')
	uptimeMetric = dict({ 'uptime': uptimeInfo[0].strip(), 'idleTime': uptimeInfo[1].strip() })
uptimeMetricJson = json.dumps(uptimeMetric)

eth0Metric = dict({})
with open('/proc/net/dev') as fd:
	lines = list(map(lambda x: x.strip(), fd.readlines()))
	lines = lines[1:]

	lines[0] = lines[0].replace('|', ':', 1)
	lines[0] = lines[0].replace('|', ' ', 1)
	lines[0] = lines[0].split(':')[1]

	keys = re.split('\s+', lines[0])
	keys = list(map(lambda x: 'rx' + x[1] if x[0] < 8 else 'tx' + x[1], enumerate(keys)))

	ifaces = {}
	for line in lines[1:]:
		interface, values = line.split(':')
		values = re.split('\s+', values)

		if values[0] == '':
			values = values[1:]

		values = list(map(int, values))

		ifaces[interface] = dict(zip(keys, values))
	eth0Metric = ifaces['eth0']

eth0MetricJson = json.dumps(eth0Metric)

monitorFileName = "{}-awesome-monitoring.log".format(currentDate)
monitorFilePath = "/var/log/{}".format(monitorFileName)

if not os.path.exists(monitorFilePath):
    os.mknod(monitorFilePath)

with open(monitorFilePath, 'a') as monitorFile:
	monitorString = "{}\n{}\n{}\n{}\n{}\n".format(
		int(now.timestamp()),
		cpuMetricsJson,
		memInfoMetricJson,
		uptimeMetricJson,
		eth0MetricJson,
	)
	monitorFile.write(monitorString)
