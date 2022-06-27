
# ClusterMon Wrapper for Generic Alerting 

This project is a wrapper for ClusterMon 

From the man page:  ocf_heartbeat_ClusterMon (7) - Runs crm_mon in the background, recording the cluster status (events) to an HTML file.


## Technical Details

A Pacemaker cluster is an event driven system. In this context, an event is a resource failure or configuration change (not exhaustive). 

ClusterMon resource agent parameter and details can be found in the man page ocf_heartbeat_ClusterMon (7), under <http://linux-ha.org/doc/man-pages/re-ra-ClusterMon.html>, on github <https://github.com/ClusterLabs/resource-agents/blob/main/heartbeat/ClusterMon> or with crm:

    crm(live)ra# info ClusterMon

The `ocf:heartbeat:ClusterMon` resource can monitor the cluster status and triggers alerts on each cluster event. This resource runs crm_mon in the background at regular intervals (configurable) and uses crm_mon capabilities to send emails (SMTP), SNMP traps or to execute an external program via the extra_options parameter. It works by using crm_mon in the background, which is a binary that provides a summary of cluster’s current state. This binary has a couple options to send email (SMTP) or traps (SNMP) on any transition to a chosen recipient. Therefore you need a crm_mon binary that supports sending SNMP or SMTP!

## No more mail support in ClusterMon! New helper script for sending mail

At least it seems that SLES15 has dropped the mail-to option from crm_mon. So we need to write a workaround around that is using a little helper script (and filter script) :-(

### SLES12+SLES15 and a helper script

ClusterMon must run on all cluster nodes, therefore we define it as a clone resource.

(crm_mail_agent.sh)

    primitive rsc_ClusterMon ocf:pacemaker:ClusterMon \
      params user=root update=10000 pidfile="/crm_scripts/crm_monitor/crmMon.pid" \
      htmlfile="/crm_scripts/crm_monitor/crmHtml.html"  \
      extra_options="-E /crm_scripts/crm_monitor/crm_mail_agent.sh" \
      op monitor on-fail=restart interval=60

    clone ClusterMon-clone rsc_ClusterMon \
      meta target-role=Started

This package/file is hosted on <https://github.com/roseswe/ClusterMon>

### SLES11 and maybe other distros

(Feedback highly appreciated)

    primitive rsc_ClusterMon ocf:pacemaker:ClusterMon \
        params user=root update=30 extra_options="--mail-to=root" \
        op monitor on-fail=restart interval=60

    clone ClusterMon-clone rsc_ClusterMon \
        meta target-role=Started

<!-- vim:set fileencoding=utf8 fileformat=unix filetype=gfm tabstop=2 expandtab:
@(#)$Id: README.md,v 1.2 2022/04/06 11:13:07 ralph Exp $  -->
