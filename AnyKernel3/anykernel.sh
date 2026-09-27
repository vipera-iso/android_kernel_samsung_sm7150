### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Prime Kernel (LostPrime) SukiSU+KPM+Tools
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=m51
device.name2=m51nsxx
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
attributes() {
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;
} # end attributes

# boot shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot;

device=$(file_getprop /system/build.prop ro.product.system.device);
android=$(file_getprop /system/build.prop ro.build.version.sdk);
oneui=$(file_getprop /system/build.prop ro.build.version.oneui);

patch_cmdline "android.is_aosp" "";

if [ "$android" -lt 34 ]; then
   ui_print " ";
   ui_print "Android 13 detected!";
   patch_cmdline "android.legacy_ebpf=" "android.legacy_ebpf=1";
fi

if [ -z "$device" ] && [ -z "$android" ]; then
    ui_print " ";
    ui_print "Skipping ROM detection...";
    ui_print " ";
else
    if [ -n "$oneui" ]; then
        ui_print " ";
        ui_print "OneUI ROM detected!";
        ui_print " ";
    elif [ "$device" == "generic" ]; then
        ui_print " ";
        ui_print "GSI ROM detected!";
        ui_print " ";
    else
        ui_print " ";
        ui_print "AOSP ROM detected!";
        ui_print " ";
        patch_cmdline "android.is_aosp" "android.is_aosp=1";
    fi
fi

write_boot;
## end boot install

### Install KPM tools (kpmcli + hello.kpm + test script)
# Kernel nay co CONFIG_KPM=y, superkey = "lostprime".
# Tools nam trong thu muc kpm/ cua zip (doc lap voi Image/dtb).
ui_print " ";
ui_print "Installing KPM tools...";

KPMDST=/data/adb/ksu/kpm;
mkdir -p $KPMDST;
cp -f $home/kpm/kpmcli $KPMDST/kpmcli;
cp -f $home/kpm/kptools-android $KPMDST/kptools;
cp -f $home/kpm/hello.kpm $KPMDST/hello.kpm;
cp -f $home/kpm/test-kpm.sh $KPMDST/test-kpm.sh;
chmod 755 $KPMDST/kpmcli $KPMDST/kptools $KPMDST/test-kpm.sh;
chmod 644 $KPMDST/hello.kpm;

ui_print "  kpmcli     -> $KPMDST/kpmcli";
ui_print "  kptools    -> $KPMDST/kptools";
ui_print "  hello.kpm  -> $KPMDST/hello.kpm";
ui_print "  test-kpm   -> $KPMDST/test-kpm.sh";
ui_print " ";
ui_print "KPM superkey: lostprime";
ui_print "Test sau khi boot:";
ui_print "  su -c 'sh /data/adb/ksu/kpm/test-kpm.sh'";
ui_print " ";
## end KPM tools install
