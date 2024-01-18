# Conditional sensitive properties

resetprop_if_diff() {
    local NAME=$1
    local EXPECTED=$2
    local CURRENT=$(resetprop $NAME)
    
    [ -z "$CURRENT" ] || [ "$CURRENT" == "$EXPECTED" ] || resetprop -n $NAME $EXPECTED
}

resetprop_if_match() {
    local NAME=$1
    local CONTAINS=$2
    local VALUE=$3
    
    [[ "$(resetprop $NAME)" == *"$CONTAINS"* ]] && resetprop -n $NAME $VALUE
}

# Magisk recovery mode
resetprop_if_match ro.bootmode recovery unknown
resetprop_if_match ro.boot.mode recovery unknown
resetprop_if_match vendor.boot.mode recovery unknown

# SELinux
if [ -n "$(resetprop ro.build.selinux)" ]; then
    resetprop --delete ro.build.selinux
fi

# use toybox to protect *stat* access time reading
if [ "$(toybox cat /sys/fs/selinux/enforce)" == "0" ]; then
    chmod 640 /sys/fs/selinux/enforce
    chmod 440 /sys/fs/selinux/policy
fi

# late props which must be set after boot_completed for various OEMs
until [ "$(resetprop sys.boot_completed)" == "1" ]; do
    sleep 1
done

# Avoid breaking Realme fingerprint scanners
resetprop_if_diff ro.boot.flash.locked 1

# Avoid breaking Oppo fingerprint scanners
resetprop_if_diff ro.boot.vbmeta.device_state locked

# Avoid breaking OnePlus display modes/fingerprint scanners
resetprop_if_diff vendor.boot.verifiedbootstate green

# Avoid breaking OnePlus/Oppo display fingerprint scanners on OOS/ColorOS 12+
resetprop_if_diff ro.boot.verifiedbootstate green
resetprop_if_diff ro.boot.veritymode enforcing
resetprop_if_diff vendor.boot.vbmeta.device_state locked

# Restrict permissions to socket file
chmod 440 /proc/net/unix
