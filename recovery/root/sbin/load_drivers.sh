#!/sbin/sh

load_panel_modules()
{
    path=$1
    panel_supplier=""
    panel_supplier=$(cat /sys/devices/virtual/graphics/fb0/panel_supplier 2> /dev/null)

    case $panel_supplier in
        csot)
            insmod $path/nova_mmi.ko
            ;;
	ofilm)
	    insmod $path/focaltech_mmi.ko
	    ;;
	tianma)
	    insmod $path/ilitek_mmi.ko
	    ;;
        *)
            echo "$panel_supplier not supported"
            ;;
    esac
}

# Main
SLOT=`getprop ro.boot.slot_suffix`
mount /dev/block/bootdevice/by-name/vendor$SLOT /vendor -o ro

# MMI Common
insmod /vendor/lib/modules/exfat.ko
insmod /vendor/lib/modules/utags.ko
insmod /vendor/lib/modules/sensors_class.ko
insmod /vendor/lib/modules/mmi_annotate.ko
insmod /vendor/lib/modules/mmi_info.ko
insmod /vendor/lib/modules/tzlog_dump.ko
insmod /vendor/lib/modules/mmi_sys_temp.ko

# Ocean specific?
insmod /vendor/lib/modules/tps61280.ko
insmod /vendor/lib/modules/drv2624_mmi.ko
insmod /vendor/lib/modules/sx932x_sar.ko

# Load panel modules
if [ -d /vendor/lib/modules ]; then
    load_panel_modules /vendor/lib/modules
else
    # In case /vendor is empty for whatever reason
    # make sure at least touchscreen is working
    load_panel_modules /sbin/modules
fi

umount /vendor
setprop drivers.loaded 1

