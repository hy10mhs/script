#!/bin/bash

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install it and configure your credentials."
        exit 1
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 [-i INSTANCE_ID] [-p IP_ADDRESS] [-n INSTANCE_NAME] [-s INSTANCE_STATE] [-r REGION] [-f PROFILE] [-t TAG_KEY=TAG_VALUE] [-m MAX_ITEMS]"
    echo "Example: $0 -t Environment=Production -r us-west-2 -f myprofile -m 10"
    exit 1
}

# Function to get instance information by instance ID
get_instance_info_by_id() {
    local instance_id=$1
    local region=$2
    local profile=$3
    aws ec2 describe-instances --instance-ids "$instance_id" --region "$region" --profile "$profile" --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,IP:PrivateIpAddress,Tags:Tags}" --output table
}

# Function to get instance information by IP address
get_instance_info_by_ip() {
    local ip_address=$1
    local region=$2
    local profile=$3
    aws ec2 describe-instances --filters "Name=private-ip-address,Values=$ip_address" --region "$region" --profile "$profile" --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,IP:PrivateIpAddress,Tags:Tags}" --output table
}

# Function to get instance information by instance name (tag key 'Name' with wildcard)
get_instance_info_by_name() {
    local instance_name=$1
    local region=$2
    local profile=$3
    aws ec2 describe-instances --filters "Name=tag:Name,Values=*$instance_name*" --region "$region" --profile "$profile" --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,IP:PrivateIpAddress,Tags:Tags}" --output table
}

# Function to get instance information by instance state
get_instance_info_by_state() {
    local instance_state=$1
    local region=$2
    local profile=$3
    aws ec2 describe-instances --filters "Name=instance-state-name,Values=$instance_state" --region "$region" --profile "$profile" --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,IP:PrivateIpAddress,Tags:Tags}" --output table
}

# Function to get instance information by tag value with result limiting
get_instance_info_by_tag() {
    local tag_key=$1
    local tag_value=$2
    local region=$3
    local profile=$4
    local max_items=$5  # Maximum number of items to return

    aws ec2 describe-instances --filters "Name=tag:$tag_key,Values=$tag_value" --region "$region" --profile "$profile" --max-items "$max_items" --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,IP:PrivateIpAddress,Tags:Tags}" --output table
}

# Function to get all instance information
get_all_instance_info() {
    local region=$1
    local profile=$2
    aws ec2 describe-instances --region "$region" --profile "$profile" --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,IP:PrivateIpAddress,Tags:Tags}" --output table
}

# Main script execution
region="us-west-2"  # Default region
profile="default"   # Default profile
max_items=100       # Default maximum items to return

# Parse command line options
while getopts "i:p:n:s:r:f:t:m:" opt; do
    case ${opt} in
        i ) instance_id=$OPTARG
            ;;
        p ) ip_address=$OPTARG
            ;;
        n ) instance_name=$OPTARG
            ;;
        s ) instance_state=$OPTARG
            ;;
        r ) region=$OPTARG
            ;;
        f ) profile=$OPTARG
            ;;
        t )
            if [[ "$OPTARG" =~ ^([^=]+)=([^=]+)$ ]]; then
                tag_key=${BASH_REMATCH[1]}
                tag_value=${BASH_REMATCH[2]}
            else
                echo "Error: Invalid tag format. Use TAG_KEY=TAG_VALUE"
                usage
            fi
            ;;
        m ) max_items=$OPTARG
            ;;
        * ) usage
            ;;
    esac
done

# Check if AWS CLI is installed
check_aws_cli

# Fetch and display instance information based on provided parameters
if [ -n "$instance_id" ]; then
    get_instance_info_by_id "$instance_id" "$region" "$profile"
elif [ -n "$ip_address" ]; then
    get_instance_info_by_ip "$ip_address" "$region" "$profile"
elif [ -n "$instance_name" ]; then
    get_instance_info_by_name "$instance_name" "$region" "$profile"
elif [ -n "$instance_state" ]; then
    get_instance_info_by_state "$instance_state" "$region" "$profile"
elif [ -n "$tag_key" ] && [ -n "$tag_value" ]; then
    get_instance_info_by_tag "$tag_key" "$tag_value" "$region" "$profile" "$max_items"
else
    get_all_instance_info "$region" "$profile"
fi

echo "Instance information fetched successfully."
