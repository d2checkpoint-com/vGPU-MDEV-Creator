#!/bin/bash

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
    echo "Script must be run as root, obtaining SU permissions and restarting."
    exec sudo "$0" "$@"
fi

# Parse command line arguments
while getopts ":P:n:f:F:" opt; do
    case $opt in
        P) profile="$OPTARG" ;;
        n) number="$OPTARG" ;;
        f) file_name="$OPTARG" ;;
        F) folder="$OPTARG" ;;
        *) echo "Usage: $0 -P <Nvidia Profile> -n <Number of mdev devices> [-f <file name>] [-F <base folder>]" >&2
           exit 1 ;;
    esac
done

# Set default values for optional arguments
file_name=${file_name:-"vgpu"}
folder=${folder:-"/vgpu"}

# Get GPU information
gpu_output=$(lshw -C display)

# Check if there are multiple GPUs and prompt the user to select one
num_gpus=$(echo "$gpu_output" | grep -c "pci@")
if [ "$num_gpus" -gt 1 ]; then
    echo "$gpu_output"
    echo "Multiple GPUs detected, please input the number for the selected card:"
    read gpu_number
else
    gpu_number=1
fi

gpu_address=$(echo "$gpu_output" | grep "pci@" | sed "${gpu_number}q;d" | awk '{print $2}')

# Create base folder if it doesn't exist
mkdir -p "$folder"

# Check for the existence of UUIDs file and append new UUIDs to it
uuids_file="$folder/$file_name.uuid"
touch "$uuids_file"
for i in $(seq 1 "$number"); do
    uuid=$(uuidgen)
    echo "$uuid" >> "$uuids_file"

    # Create XML files for each UUID
    xml_file="$folder/$file_name/$(basename "$uuid").xml"
    mkdir -p "$(dirname "$xml_file")"
    cat > "$xml_file" <<- EOM
<device>
    <parent>pci_${gpu_address//:/_}</parent>
    <capability type="mdev">
        <type id="$profile"/>
        <uuid>$uuid</uuid>
    </capability>
</device>
EOM

    # Define and start mdev devices using the XML files
    node_dev=$(virsh nodedev-define "$xml_file")
    if [ $? -ne 0 ]; then
        echo "Error defining mdev device from $xml_file, exiting."
        exit 1
    fi

    echo "$node_dev"
    node_dev_name=$(echo "$node_dev" | awk '{print $4}')

    if ! virsh nodedev-start "$node_dev_name"; then
        echo "Error starting mdev device $node_dev_name, exiting."
        exit 1
    fi

    if ! virsh nodedev-autostart "$node_dev_name"; then
        echo "Error setting mdev device $node_dev_name to autostart, exiting."
        exit 1
    fi
done

# Verify that all mdev devices are active
virsh nodedev-list --cap mdev

echo "Script completed successfully."
