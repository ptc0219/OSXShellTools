user=$(sudo whoami)
if [ "$user" = "root" ]; then
    devs=$(sudo ls /var/db/dhcpclient/leases)
    for dev in $devs
    do
        leaseTime=$(sudo /usr/libexec/PlistBuddy -c "print :LeaseLength" /var/db/dhcpclient/leases/$dev)
        echo "${dev%-*} Lease time: $leaseTime"s
    done
else
    echo "Usage: sudo $0"
fi
