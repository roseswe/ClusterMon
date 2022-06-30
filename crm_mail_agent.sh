#!/bin/bash
# vim:set fileencoding=utf8 fileformat=unix filetype=shell tabstop=2 expandtab:
# @(#)$Id: crm_mail_agent.sh,v 1.7 2022/03/02 14:37:41 ralph Exp $
# SLES15 and SLES12 dropped the --mail-to option in crm_mon, so we have to emulate this with this script
# also this script only logs critical events, where the original mail-to option more or less spams you.

# Example: /crm_scripts/crm_monitor/crm_mail_agent.sh
# this resolves to
# /usr/sbin/crm_mon -p /tmp/ClusterMon_rsc_ClusterMon.pid -d -i 30 -E /crm/scripts/crm_mail_agent.sh -h /crm/scripts/crmHtml.html


# change the following values

SENDER="CRMMonitor@customer.com"             ## valid user, else we end in spam or get rejected!
RECEIVER="ralph.roth@customer.com"           ## Additional receiver
HAWKLINK="https://10.66.3.89:7630/cib/live"  ## CHANGEME too!  VIP address

# wait until HTML file is generated successfully
sleep 3

# grep cluster status html file and add a link to Hawklink to it
HTMLTEXT=`cat /crm_scripts/crm_monitor/crmHtml.html`
HAWKLINK="<a href=${HAWKLINK}>Click here to open HAWK Cluster Admin Interface</a><br/><b>Stack:</b>"
HTMLTEXT="${HTMLTEXT/"<b>Stack:</b>"/$HAWKLINK}"

# generate mail subject with causing node, resource + description and date
SUBJ="${CRM_notify_node}: ${CRM_notify_rsc} ${CRM_notify_desc} at $(date) "

# Debug
echo "$(date) - ${CRM_notfiy_node} ${CRM_notify_task}: ${CRM_notify_rsc} ${CRM_notify_desc} ${CRM_notify_rc}" >> /crm_scripts/crm_monitor/crmstate.log

# if [[ unsuccessful monitor operation aka not running ]]

if [[ ${CRM_notify_rc} != 0 && ${CRM_notify_task} == "monitor" && ${CRM_notify_desc} == "not running"  ]]  ## Couldn't parse this if expression. Fix to allow more checks.
then

    # send info to file to reference to it later
    echo "$CRM_notify_node" > /crm_scripts/crm_monitor/crm_current_error
    echo "$CRM_notify_rsc" >> /crm_scripts/crm_monitor/crm_current_error

    # send mail with error
    (
        echo "From: $SENDER "
        echo "To: $RECEIVER "
        echo "MIME-Version: 1.0"
        echo "Content-Type: multipart/alternative; "
        echo ' boundary="ClusterMonitoring by CustomerChangeMe"'
        echo "Subject: $SUBJ"
        echo ""
        echo "This is a MIME-encapsulated message"
        echo ""
        echo "--ClusterMonitoring by CustomerChangeMe"
        echo "Content-Type: text/html"
        echo ""
        echo "$HTMLTEXT"
    ) | sendmail -t

    # else if [[ successful monitor operation of already failed resource]]
    # ClusterMon-Easy:::20220630-111057,ralph152,rsc_ClusterMon,monitor,OK,0,0,0,:::
elif [[ ${CRM_notify_task} == "monitor" && ${CRM_notify_desc} == "OK" &&  -f /crm_scripts/crm_monitor/crm_current_error ]]
then

    # read in error reference file
    COUNTER=0
    while IFS='' read -r line || [[ -n "$line" ]]
    do
        if [ "$COUNTER" -eq 0 ]
        then
            LASTNODE=$line
            COUNTER=1
        else
            LASTERROR=$line
        fi
    done < "/crm_scripts/crm_monitor/crm_current_error"

    # check if OK MSG is for reference error
    if [[ "${LASTNODE}" == ${CRM_notify_node} && "${LASTERROR}" == ${CRM_notify_rsc} ]]
    then

        # remove error reference file and clear failed resource
        rm /crm_scripts/crm_monitor/crm_current_error
        crm resource cleanup ${CRM_notify_rsc}

        # send mail with OK MSG
        (
            echo "From: $SENDER "
            echo "To: $RECEIVER "
            echo "MIME-Version: 1.0"
            echo "Content-Type: multipart/alternative; "
            echo ' boundary="ClusterMonitoring by CustomerChangeMe"'
            echo "Subject: $SUBJ"
            echo ""
            echo "This is a MIME-encapsulated message"
            echo "--ClusterMonitoring by CustomerChangeMe"
            echo "Content-Type: text/html"
            echo ""
            echo "$HTMLTEXT"
        ) | sendmail -t

    fi
    echo "Content-Type: multipart/alternative; "
    echo ' boundary="ClusterMonitoring by ClusterMon"'
    echo "Subject: $SUBJ"
    echo ""
    echo "This is a MIME-encapsulated message"
    echo "--ClusterMonitoring by ClusterMon"
    echo "Content-Type: text/html"
    echo ""
    echo "$HTMLTEXT"
) | sendmail -t

  fi
fi

exit 0
