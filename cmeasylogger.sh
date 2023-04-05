#!/bin/bash
# ClusterMon Wrapper Script, easiest example
#

# this will log to system syslog (e.g. /var/log/messages)
logger -t "ClusterMon-Easy:" "${CRM_notify_node} ${CRM_notify_rsc} \
  ${CRM_notify_task} ${CRM_notify_desc} ${CRM_notify_rc} \
  ${CRM_notify_target_rc} ${CRM_notify_status} ${CRM_notify_recipient}";

# this will "echo" append to a local logfile
# ClusterMon-Easy:::20220630-111057,ralph152,rsc_ClusterMon,monitor,pending,193,0,-1,:::

# get the fail count of the resource for later usage
FC=$(/usr/sbin/crm resource failcount ${CRM_notify_rsc} show ${CRM_notify_node} 2>&1 | awk -F"value=" '{print $2+0;}')

##                                  -1-             -2-                 -3-               -4-                -5-
echo "ClusterMon-Easy:::$(date +%Y%m%d-%H%M%S),${CRM_notify_node},${CRM_notify_rsc},${CRM_notify_task},${CRM_notify_desc},${CRM_notify_rc},${CRM_notify_target_rc},${CRM_notify_status},${CRM_notify_recipient},${FC},$$:::" >> /root/cm_easylogger.txt

## -4-
## monitor st_notify_fence start stop

# unset for debugging variables that are passed to this script
# set| grep -i -e CRM_ -e PCMK_ -e OCF_  > /root/cm_el_env.txt


## vim:set fileencoding=utf8 fileformat=unix filetype=shell tabstop=2 expandtab:
## @(#)$Id: cmeasylogger.sh,v 1.3 2022/06/30 18:00:12 ralph Exp $
