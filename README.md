# ClusterMon Wrapper for Generic Pacemaker Cluster Alerting

This project is a set of different (shellscript) wrappers for the ClusterMon resource agent addressing different use cases to be used as a blue print.

From the man page:  ocf_heartbeat_ClusterMon (7) - Runs crm_mon in the background, recording the cluster status (events) to an HTML file.

## Technical Details

A pacemaker cluster is an event driven system. In this context, an event is a resource failure or configuration change (not exhaustive).

ClusterMon resource agent parameter and details can be found in the man page ocf_heartbeat_ClusterMon (7) [older]/ocf_pacemaker_ClusterMon (7), under <http://linux-ha.org/doc/man-pages/re-ra-ClusterMon.html>, on github <https://github.com/ClusterLabs/resource-agents/blob/main/heartbeat/ClusterMon> or with crm:

    # crm ra info ClusterMon

The `ocf:heartbeat:ClusterMon` resource can monitor the cluster status and triggers alerts on each cluster event. This resource runs crm_mon in the background at regular intervals (configurable) and uses crm_mon capabilities to send emails (SMTP), SNMP traps or to execute an external program via the extra_options parameter. It works by using crm_mon in the background, which is a binary that provides a summary of cluster’s current state. This binary has a couple options to send email (SMTP) or traps (SNMP) on any transition to a chosen recipient. Therefore you need a crm_mon binary that supports sending SNMP or SMTP, if not see workaround script `crm_mail_agent.sh`!

On SUSE SLES15 `crm_mon` comes with the package pacemaker-cli.

## ClusterMon Easy Logger Script

This is a very primitive script that simply output cluster changes to syslog (via logger) and into a local text file.

The pacemaker primitive definition and clone set to use this script

    primitive rsc_ClusterMonEL ocf:pacemaker:ClusterMon \
            params user=root update=10000 htmlfile="/tmp/cmeasylogger.html" extra_options="-E /root/bin/cmeasylogger.sh -W" \
            op monitor on-fail=restart interval=60
    clone ClusterMon-clone rsc_ClusterMonEL \
            meta target-role=Started

Copy and chmod +x the cmeasylogger.sh file to all nodes :-)

If you want to play around and testing the provided scripts you can create a dummy resource. Example:

    # crm configure show rsc_Dummy01
    primitive rsc_Dummy01 Dummy \
    meta target-role=Started \
    op start timeout=20s interval=0s \
    op stop timeout=20s interval=0s \
    op monitor timeout=20s interval=10s


Example output of created logfile (/root/cm_easylogger.txt):

    # tail cm_easylogger.txt
    ClusterMon-Easy:::20220629-170649,sap12ha1,rsc_ClusterMon,monitor,ok,0,7,0,:::
    ClusterMon-Easy:::20220629-170649,sap12ha2,admin-ip,stop,OK,0,0,0,:::
    ClusterMon-Easy:::20220629-170649,sap12ha2,mariadb-ip,stop,OK,0,0,0,:::
    ClusterMon-Easy:::20220629-170649,sap12ha1,rsc_ClusterMon,monitor,OK,0,0,0,:::
    ClusterMon-Easy:::20220629-170649,sap12ha1,admin-ip,start,unknown error,1,0,0,:::
    ClusterMon-Easy:::20220629-170649,sap12ha1,mariadb-ip,start,unknown error,1,0,0,:::
    ClusterMon-Easy:::20220629-170649,sap12ha1,admin-ip,start,unknown error,1,0,0,:::
    ClusterMon-Easy:::20220629-170649,sap12ha1,mariadb-ip,start,unknown error,1,0,0,:::
    ClusterMon-Easy:::20220629-170650,sap12ha1,admin-ip,stop,OK,0,0,0,:::
    ClusterMon-Easy:::20220629-170650,sap12ha1,mariadb-ip,stop,OK,0,0,0,:::

Other example on SLES15SP5 KVM Cluster

    kvm02cs:~ # cat cm_easylogger.txt
    ClusterMon-Easy:::20250224-170300,kvm01cs,rsc_ClusterMonEL,monitor,OK,0,0,0,,0,4778:::
    ClusterMon-Easy:::20250224-170300,kvm02cs,rsc_ClusterMonEL,monitor,OK,0,0,0,,0,4775:::
    ClusterMon-Easy:::20250224-170639,kvm01cs,rsc_ClusterMonEL,stop,pending,193,0,-1,,0,6317:::
    ClusterMon-Easy:::20250224-170639,kvm01cs,rsc_ClusterMonEL,stop,OK,0,0,0,,0,6325:::
    ClusterMon-Easy:::20250224-170716,kvm01cs,rsc_ClusterMonEL,start,pending,193,0,-1,,0,6654:::
    ClusterMon-Easy:::20250224-170717,kvm01cs,rsc_ClusterMonEL,start,OK,0,0,0,,0,6664:::
    ClusterMon-Easy:::20250224-170717,kvm01cs,rsc_ClusterMonEL,monitor,pending,193,0,-1,,0,6666:::
    ClusterMon-Easy:::20250224-170717,kvm01cs,rsc_ClusterMonEL,monitor,OK,0,0,0,,0,6680:::
    ClusterMon-Easy:::20250224-170734,kvm02cs,rsc_Dummy01,monitor,pending,193,0,-1,,0,6862:::
    ClusterMon-Easy:::20250224-170734,kvm02cs,rsc_Dummy01,monitor,OK,0,0,0,,0,6877:::
    ClusterMon-Easy:::20250224-170734,kvm02cs,rsc_Dummy01,start,OK,0,0,0,,0,6860:::
    ClusterMon-Easy:::20250224-170734,kvm01cs,rsc_Dummy01,stop,pending,193,0,-1,,0,6830:::
    ClusterMon-Easy:::20250224-170734,kvm02cs,rsc_Dummy01,start,pending,193,0,-1,,0,6851:::
    ClusterMon-Easy:::20250224-170734,kvm01cs,rsc_Dummy01,stop,OK,0,0,0,,0,6841:::
    ClusterMon-Easy:::20250224-171211,kvm01cs,rsc_vd_cirros,monitor,not running,7,0,0,,1,9077:::
    ClusterMon-Easy:::20250224-171211,kvm01cs,rsc_vd_cirros,stop,pending,193,0,-1,,1,9082:::
    ClusterMon-Easy:::20250224-171211,kvm01cs,rsc_vd_cirros,stop,OK,0,0,0,,1,9087:::
    ClusterMon-Easy:::20250224-171211,kvm01cs,rsc_vd_cirros,start,pending,193,0,-1,,1,9092:::
    ClusterMon-Easy:::20250224-171213,kvm01cs,rsc_vd_cirros,start,OK,0,0,0,,1,9215:::
    ClusterMon-Easy:::20250224-171213,kvm01cs,rsc_vd_cirros,monitor,pending,193,0,-1,,1,9217:::
    ClusterMon-Easy:::20250224-171213,kvm01cs,rsc_vd_cirros,monitor,OK,0,0,0,,1,9245:::

Note: crm node fence kvm01cs

    ClusterMon-Easy:::20250224-171421,kvm01cs,rsc_vd_cirros,st_notify_fence,Operation reboot of kvm01cs by kvm02cs for pacemaker-controld.8623@kvm02cs: OK (ref=6259287c-e825-493c-9f0a-527830618b15),0,0,0,,0,10203:::
    ClusterMon-Easy:::20250224-171421,kvm02cs,rsc_vd_cirros,start,pending,193,0,-1,,0,10220:::
    ClusterMon-Easy:::20250224-171421,kvm02cs,rsc_vd_cirros,start,OK,0,0,0,,0,10263:::
    ClusterMon-Easy:::20250224-171421,kvm02cs,rsc_vd_cirros,monitor,pending,193,0,-1,,0,10264:::
    ClusterMon-Easy:::20250224-171421,kvm02cs,rsc_vd_cirros,monitor,OK,0,0,0,,0,10395:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,sbd-fencing,monitor,OK,0,0,0,,0,10676:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_vd_cirros,monitor,OK,0,0,0,,0,10682:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_ClusterMonEL,monitor,OK,0,0,0,,0,10672:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_vd_cirros,start,OK,0,0,0,,0,10679:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_cl_NodeUtil,start,OK,0,0,0,,0,10673:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,sbd-fencing,start,OK,0,0,0,,0,10675:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_ClusterMonEL,start,OK,0,0,0,,0,10671:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,sbd-fencing,monitor,pending,193,7,-1,,0,10727:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_vd_cirros,monitor,pending,193,7,-1,,0,10739:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_cl_NodeUtil,monitor,pending,193,7,-1,,0,10740:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_vd_sles15,monitor,OK,0,0,0,,0,10684:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_Dummy01,start,OK,0,0,0,,0,10669:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_vd_sles15,start,OK,0,0,0,,0,10683:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_ClusterMonEL,monitor,pending,193,7,-1,,0,10737:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_cl_NodeUtil,start,pending,193,0,-1,,0,10751:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_cl_NodeUtil,monitor,pending,193,0,-1,,0,10765:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_ClusterMonEL,start,pending,193,0,-1,,0,10752:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_Dummy01,monitor,OK,0,0,0,,0,10670:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_ClusterMonEL,monitor,OK,0,0,0,,0,10791:::
    ClusterMon-Easy:::20250224-171444,kvm02cs,rsc_cl_NodeUtil,monitor,OK,0,0,0,,0,10674:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_vd_sles15,monitor,pending,193,7,-1,,0,10741:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_Dummy01,monitor,pending,193,7,-1,,0,10729:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_cl_NodeUtil,start,OK,0,0,0,,0,10764:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_ClusterMonEL,monitor,pending,193,0,-1,,0,10785:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_ClusterMonEL,start,OK,0,0,0,,0,10784:::
    ClusterMon-Easy:::20250224-171444,kvm01cs,rsc_cl_NodeUtil,monitor,OK,0,0,0,,0,10782:::


### Debugging ClusterMon and the Easy Logger Script by hand

    crm_mon -d -i 5 --output-as=html --output-to=/tmp/cmel.html -E "/root/bin/cmeasylogger.sh" --watch-fencing

Note:         -W, --watch-fencing
              Listen for fencing events. For use with --external-agent.

## No more mail support in ClusterMon! New helper script for sending mail

At least it seems that SLES12 has dropped the mail-to option from crm_mon. So we need to write a workaround around that is using a little helper script (and filter script) :-(

### SLES12+SLES15 and a helper script

ClusterMon must run on all cluster nodes, therefore we define it as a clone resource.

crm_mail_agent.sh - example CIB (must be adapted to your environment):

    primitive rsc_ClusterMon ocf:pacemaker:ClusterMon \
      params user=root update=10000 pidfile="/crm_scripts/crm_monitor/crmMon.pid" \
      htmlfile="/crm_scripts/crm_monitor/crmHtml.html"  \
      extra_options="-E /crm_scripts/crm_monitor/crm_mail_agent.sh" \
      op monitor on-fail=restart interval=60

    clone ClusterMon-clone rsc_ClusterMon \
      meta target-role=Started

NOTE:  Changing the shell script (e.g. crm_mail_agent.sh) will be executed the next monitor interval with your changes. So you can edit it on the fly.

This package/file is hosted on <https://github.com/roseswe/ClusterMon>

### SLES11 and maybe other distros, Get Mail

(Feedback highly appreciated)

    primitive rsc_ClusterMon ocf:pacemaker:ClusterMon \
        params user=root update=30 extra_options="--mail-to=root" \
        op monitor on-fail=restart interval=60

    clone ClusterMon-clone rsc_ClusterMon \
        meta target-role=Started

## Available Variables for crm_mon

At least valid for pacemaker 1.x and 2.0

    Environment Variable    Description
    CRM_notify_desc         The textual output relevant error code of the operation (if any) that caused the status change
    CRM_notify_node         The node on which the status change happened
    CRM_notify_rc           The return code of the operation
    CRM_notify_recipient    The static external-recipient from the resource definition
    CRM_notify_rsc          The name of the resource that changed the status
    CRM_notify_status       The numerical representation of the status of the operation
    CRM_notify_task         The operation that caused the status change
    CRM_notify_target_rc    The expected return code of the operation

Source:  <https://clusterlabs.org/pacemaker/doc/deprecated/en-US/Pacemaker/1.1/html/Pacemaker_Explained/s-notification-external.html>  and <https://fossies.org/linux/pacemaker/lib/common/alerts.c>

Tested with SLES12SP5, SLES15SP2 and SLES15SP4

    # crm_mon --version
    # SLES15SP2
    Pacemaker 2.0.4+20200616.2deceaa3a-3.15.1
    Written by Andrew Beekhof
    # SLES15SP4
    Pacemaker 2.1.2+20211124.ada5c3b36-150400.2.43
    Written by Andrew Beekhof
    # SLES15SP5
    Pacemaker 2.1.5+20221208.a3f44794f-150500.6.20.1
    Written by Andrew Beekhof and the Pacemaker project contributors


/*end*/
<!-- vim:set fileencoding=utf8 fileformat=unix filetype=gfm tabstop=2 expandtab:
@(#)$Id: README.md,v 1.7 2025/02/24 16:25:12 ralph Exp $  -->
