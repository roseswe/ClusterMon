#!/bin/bash
# ClusterMon Wrapper Script, easiest example
#

# this will log to system syslog (e.g. /var/log/messages)
logger -t "ClusterMon-Easy:" "${CRM_notify_node} ${CRM_notify_rsc} \
  ${CRM_notify_task} ${CRM_notify_desc} ${CRM_notify_rc} \
  ${CRM_notify_target_rc} ${CRM_notify_status} ${CRM_notify_recipient}";

# this will "echo" append to a local logfile
echo "ClusterMon-Easy:::$(date +%Y%m%d-%H%M%S),${CRM_notify_node},${CRM_notify_rsc},${CRM_notify_task},${CRM_notify_desc},${CRM_notify_rc},${CRM_notify_target_rc},${CRM_notify_status},${CRM_notify_recipient}:::" >> /root/cm_easylogger.txt

# unset for debugging variables that are passed to this script
# set| grep -i -e CRM_ -e PCMK_ -e OCF_  > /root/cm_el_env.txt


## vim:set fileencoding=utf8 fileformat=unix filetype=shell tabstop=2 expandtab:
## @(#)$Id: cmeasylogger.sh,v 1.2 2022/06/28 04:50:44 ralph Exp $
