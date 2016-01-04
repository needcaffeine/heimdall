#!/bin/bash

# Usage
# heimdall.sh                -   Usage information
# heimdall.sh list           -   List all available hosts
# heimdall.sh grant|revoke   -   Grants/Revokes your IP access to the bastion security group.
# heimdall.sh <host>         -   Logs you into host via the bastion and the default user.
# heimdall.sh <user>@<host>  -   Logs you into host via the bastion and the specified user.

# What should these be for your organization?
BASTION_HOST_NAME=
BASTION_DNS_NAME=
BASTION_SECURITY_GROUP_ID=
SSH_KEY_FILE=~/.ssh/id_rsa


###############################################################################
# Do not modify the script below this line unless you know what you're doing. #
###############################################################################

# Read in any positional arguments that were passed in.
args=("$@")
numArgs=($#)

# If this script was invoked without any arguments, display usage information.
if [[ $numArgs -eq 0 ]]
then
    echo usage:
    echo "heimdall.sh                -   Usage information"
    echo "heimdall.sh list           -   List all available hosts"
    echo "heimdall.sh grant|revoke   -   Grants/Revokes your IP access to the bastion security group."
    echo "heimdall.sh <host>         -   Logs you into host via the bastion and the default user."
    echo "heimdall.sh <user>@<host>  -   Logs you into host via the bastion and the specified user."
    exit
fi

case ${args[0]} in
    grant|revoke )
        ip=`dig +short myip.opendns.com @resolver1.opendns.com`
        case ${args[0]} in
            revoke )
                echo "Revoking your IP access to the ingress group..."
                aws ec2 revoke-security-group-ingress --group-id ${BASTION_SECURITY_GROUP_ID} --protocol tcp --port 22 --cidr ${ip}/32
                ;;
            grant )
                echo "Granting your IP access to the ingress group..."
                aws ec2 authorize-security-group-ingress --group-id ${BASTION_SECURITY_GROUP_ID} --protocol tcp --port 22 --cidr ${ip}/32
                ;;
            esac
            ;;

    list )
        echo "Listing all running instances:"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"\
            | jq -r '.Reservations[].Instances[]'\
            | jq -c '{Env: .Tags[] | select(.Key == "Env").Value, InstanceId: .InstanceId, Name: .Tags[] | select(.Key == "Name").Value}'\
            | jq -s '.|=sort_by(.Env,.Name)'\
            | jq -c '.[]'
        ;;

    bastion|* )
        # Do we need to figure out the dns name for our Bastion host?
        if [[ -z "$BASTION_DNS_NAME" ]]
        then
            if [[ -z "$BASTION_HOST_NAME" ]]
            then
                echo "ERROR: Please set either BASTION_DNS_NAME or BASTION_HOST_NAME."
                exit
            fi

            BASTION_DNS_NAME=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${BASTION_HOST_NAME}" | jq -r '.Reservations[].Instances[].PublicDnsName'`
        fi

        # If the target param contains a username, split it out so we can determine the host dns.
        host=${args[0]}
        if [[ ${host} =~ "@" ]]
        then
            user=$(echo ${host} | cut -f1 -d@)
            host=$(echo ${host} | cut -f2 -d@)
        fi

        # If a user was not provided, use the currently logged in user.
        user=${user:-$USER}

        case ${args[0]} in
            bastion )
                ssh -i ${SSH_KEY_FILE} -A -t ec2-user@${BASTION_DNS_NAME}
                ;;
            * )
                # Figure out the host dns.
                host=`aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=${host}" | jq -r '.Reservations[].Instances[].PrivateDnsName'`

                # Do the magic.
                ssh -i ${SSH_KEY_FILE} -A -t ec2-user@${BASTION_DNS_NAME} ssh -A -t ${user}@${host}
                ;;
            esac
        ;;
esac
