From: kichawa23@interia.pl
Subject: (unknown)
Date: Wed, 28 Jan 2015 15:48:43 +0100
Message-ID: <svyrqwasiqhvawbmflej@lgeu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hH6fUeRMi8urh0F4ezJc"
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo.poczta.interia.pl ([217.74.65.237]:53882 "EHLO
	smtpo.poczta.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618AbbA1U6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:58:11 -0500
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-hH6fUeRMi8urh0F4ezJc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi,

My connection is randomly picked. Symptoms are the same as a year ago. [attachment: iwlwifi.log]

My kernel:
Linux x61s 3.18.2-2-ARCH #1 SMP PREEMPT Fri Jan 9 07:23:08 CET 2015 i686 GNU/Linux
Linux x61s 3.18.4-1-ARCH #1 SMP PREEMPT Tue Jan 27 21:01:00 CET 2015 i686 GNU/Linux

My wireless controller:
02:00.0 Network controller: Intel Corporation Centrino Advanced-N 6200 (rev 35)

Thank in advance
--=-hH6fUeRMi8urh0F4ezJc
Content-Type: text/plain; name="ifconfig_wlan0_up"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="ifconfig_wlan0_up"

[ 1091.345765]  [<c106c253>] kthread+0xb3/0xd0
[ 1091.345771]  [<c1479f41>] ret_from_kernel_thread+0x21/0x30
[ 1091.345774]  [<c106c1a0>] ? kthread_create_on_node+0x130/0x130
[ 1091.345778] ---[ end trace 0c7129685113d084 ]---
[ 1091.346187] cfg80211: Calling CRDA to update world regulatory domain
[ 1091.347266] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ 1092.152886] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1092.953799] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1110.559529] thinkpad_acpi: EC reports that Thermal Table has changed
[ 1110.647118] EXT4-fs (sda5): re-mounted. Opts: data=3Dordered,commit=3D60=
0
[ 1111.251256] EXT4-fs (sda1): re-mounted. Opts: (null)
[ 1111.276142] EXT4-fs (sda6): re-mounted. Opts: data=3Dordered,commit=3D60=
0
[ 1111.357783] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1112.158623] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1112.959585] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1113.760724] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1114.561713] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1115.362895] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1116.164144] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1116.965222] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1117.766201] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1118.567244] e1000e 0000:00:19.0 eth0: Error reading PHY register
[ 1196.936806] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[ 1197.006316] iwlwifi 0000:02:00.0: Radio type=3D0x1-0x3-0x1
[ 1202.642017] iwlwifi 0000:02:00.0: Failed to load firmware chunk!
[ 1202.642029] iwlwifi 0000:02:00.0: Could not load the [0] uCode section
[ 1202.642037] iwlwifi 0000:02:00.0: Failed to start RT ucode: -110
[ 1204.435533] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 0 [0x5a5a5a5a]
[ 1206.246198] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 2 [0x5a5a5a5a]
[ 1208.092369] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 5 [0x5a5a5a5a]
[ 1209.903953] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 7 [0x5a5a5a5a]
[ 1211.668061] iwlwifi 0000:02:00.0: Unable to initialize device.
[ 1220.413655] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[ 1220.483357] iwlwifi 0000:02:00.0: Radio type=3D0x1-0x3-0x1
[ 1226.118549] iwlwifi 0000:02:00.0: Failed to load firmware chunk!
[ 1226.118558] iwlwifi 0000:02:00.0: Could not load the [0] uCode section
[ 1226.118567] iwlwifi 0000:02:00.0: Failed to start RT ucode: -110
[ 1227.911330] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 0 [0x5a5a5a5a]
[ 1229.721430] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 2 [0x5a5a5a5a]
[ 1231.566820] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 5 [0x5a5a5a5a]
[ 1233.377219] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 7 [0x5a5a5a5a]
[ 1235.140838] iwlwifi 0000:02:00.0: Unable to initialize device.
=

--=-hH6fUeRMi8urh0F4ezJc
Content-Type: text/plain; name="tained"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="tained"

4096
=

--=-hH6fUeRMi8urh0F4ezJc
Content-Type: text/plain; name="lsmod_modinfo"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="lsmod_modinfo"

filename:       /lib/modules/3.18.4-1-ARCH/kernel/fs/fuse/fuse.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/net/bluetooth/bnep/bnep.k=
o.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/bluetooth/btusb.k=
o.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/net/bluetooth/bluetooth.k=
o.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/hwmon/coretemp.ko=
.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/thermal/intel_pow=
erclamp.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/arch/x86/kvm/kvm.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/joydev.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/mousedev.ko=
.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/pci/hda/snd-hda-cod=
ec-hdmi.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/platform/x86/thin=
kpad_acpi.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/arch/x86/crypto/crc32-pcl=
mul.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/arch/x86/crypto/crc32c-in=
tel.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/pci/hda/snd-hda-cod=
ec-conexant.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/pci/hda/snd-hda-cod=
ec-generic.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/crypto/arc4.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/arch/x86/crypto/aesni-int=
el.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/net/wireless/iwlw=
ifi/dvm/iwldvm.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/char/nvram.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/watchdog/iTCO_wdt=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/watchdog/iTCO_ven=
dor_support.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/pci/hda/snd-hda-int=
el.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/pci/hda/snd-hda-con=
troller.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/pci/hda/snd-hda-cod=
ec.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/core/snd-hwdep.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/arch/x86/crypto/aes-i586.=
ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/core/snd-pcm.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/crypto/xts.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/leds/led-class.ko=
.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/net/mac80211/mac80211.ko.=
gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/net/wireless/iwlw=
ifi/iwlwifi.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/i2c/busses/i2c-i8=
01.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/hwmon/hwmon.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/core/snd-timer.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/core/snd.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/sound/soundcore.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/crypto/lrw.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/net/ethernet/inte=
l/e1000e/e1000e.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/mouse/psmou=
se.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/char/tpm/tpm_tis.=
ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/crypto/gf128mul.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/net/wireless/cfg80211.ko.=
gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/platform/x86/inte=
l_ips.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/crypto/ablk_helper.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/acpi/thermal.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/char/agp/intel-ag=
p.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/mfd/lpc_ich.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/serio/serio=
_raw.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/crypto/cryptd.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/ptp/ptp.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/char/tpm/tpm.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/pps/pps_core.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/platform/x86/wmi.=
ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/net/rfkill/rfkill.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/acpi/ac.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/pci/hotplug/shpch=
p.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/misc/mei/mei-me.k=
o.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/misc/mei/mei.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/acpi/battery.ko.g=
z
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/evdev.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/macintosh/mac_hid=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/net/sched/sch_fq_codel.ko=
.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/cpufreq/cpufreq_p=
owersave.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/cpufreq/acpi-cpuf=
req.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/acpi/processor.ko=
.gz
filename:       /lib/modules/3.18.4-1-ARCH/extramodules/vboxnetflt.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/extramodules/vboxdrv.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/fs/ext4/ext4.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/lib/crc16.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/fs/mbcache.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/fs/jbd2/jbd2.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/scsi/sd_mod.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/hid/hid-generic.k=
o.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/hid/usbhid/usbhid=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/hid/hid.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/keyboard/at=
kbd.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/serio/libps=
2.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/ata/ahci.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/ata/libahci.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/ata/libata.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/usb/host/ehci-pci=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/scsi/scsi_mod.ko.=
gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/usb/host/ehci-hcd=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/usb/core/usbcore.=
ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/usb/common/usb-co=
mmon.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/serio/i8042=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/input/serio/serio=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/gpu/drm/i915/i915=
.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/acpi/button.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/char/agp/intel-gt=
t.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/i2c/algos/i2c-alg=
o-bit.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/acpi/video.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/gpu/drm/drm_kms_h=
elper.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/gpu/drm/drm.ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/char/agp/agpgart.=
ko.gz
filename:       /lib/modules/3.18.4-1-ARCH/kernel/drivers/i2c/i2c-core.ko.g=
z
=

--=-hH6fUeRMi8urh0F4ezJc
Content-Type: text/plain; name="iwlwifi.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="iwlwifi.log"

[    2.240667] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filter=
ed out
[    2.241652] ata1.00: configured for UDMA/100
[    2.242013] scsi 0:0:0:0: Direct-Access     ATA      WDC WD1600BEKT-6 1A=
03 PQ: 0 ANSI: 5
[    2.314986] hub 1-1:1.0: USB hub found
[    2.315167] hub 1-1:1.0: 6 ports detected
[    2.328133] hub 2-1:1.0: USB hub found
[    2.328242] hub 2-1:1.0: 8 ports detected
[    2.560325] ata2: SATA link down (SStatus 0 SControl 300)
[    2.580464] usb 1-1.1: new full-speed USB device number 3 using ehci-pci
[    2.593803] Switched to clocksource tsc
[    2.667065] hub 1-1.1:1.0: USB hub found
[    2.667195] hub 1-1.1:1.0: 3 ports detected
[    2.733763] usb 1-1.3: new full-speed USB device number 4 using ehci-pci
[    2.880123] ata5: SATA link down (SStatus 0 SControl 300)
[    2.933614] usb 1-1.1.1: new full-speed USB device number 5 using ehci-p=
ci
[    3.021913] hidraw: raw HID events driver (C) Jiri Kosina
[    3.023672] usbcore: registered new interface driver usbhid
[    3.023677] usbhid: USB HID core driver
[    3.024340] input: HID 0a5c:4502 as /devices/pci0000:00/0000:00:1a.0/usb=
1/1-1/1-1.1/1-1.1.1/1-1.1.1:1.0/0003:0A5C:4502.0001/input/input6
[    3.024425] hid-generic 0003:0A5C:4502.0001: input,hidraw0: USB HID v1.1=
1 Keyboard [HID 0a5c:4502] on usb-0000:00:1a.0-1.1.1/input0
[    3.086962] usb 1-1.1.2: new full-speed USB device number 6 using ehci-p=
ci
[    3.176844] input: HID 0a5c:4503 as /devices/pci0000:00/0000:00:1a.0/usb=
1/1-1/1-1.1/1-1.1.2/1-1.1.2:1.0/0003:0A5C:4503.0002/input/input7
[    3.176968] hid-generic 0003:0A5C:4503.0002: input,hidraw1: USB HID v1.1=
1 Mouse [HID 0a5c:4503] on usb-0000:00:1a.0-1.1.2/input0
[    3.199924] ata6: SATA link down (SStatus 0 SControl 300)
[    3.204317] sd 0:0:0:0: [sda] 312581808 512-byte logical blocks: (160 GB=
/149 GiB)
[    3.204418] sd 0:0:0:0: [sda] Write Protect is off
[    3.204426] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.204471] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    3.243409] usb 1-1.1.3: new full-speed USB device number 7 using ehci-p=
ci
[    3.256658]  sda: sda1 sda2 sda3 < sda5 sda6 >
[    3.257293] sd 0:0:0:0: [sda] Attached SCSI disk
[    3.708516] EXT4-fs (sda5): mounted filesystem with ordered data mode. O=
pts: (null)
[    4.773097] random: nonblocking pool is initialized
[    4.788760] systemd[1]: RTC configured in localtime, applying delta of 6=
0 minutes to system time.
[    6.009083] systemd[1]: [/usr/lib/systemd/system/mpd.service:17] Unknown=
 lvalue 'ControlGroup' in section 'Service'
[    6.009110] systemd[1]: [/usr/lib/systemd/system/mpd.service:20] Unknown=
 lvalue 'ControlGroupAttribute' in section 'Service'
[    6.466663] thinkpad_ec: thinkpad_ec 0.41 loaded.
[    6.469279] tp_smapi 0.41 loading...
[    6.469487] tp_smapi successfully loaded (smapi_port=3D0xb2).
[    6.566841] vboxdrv: Found 4 processor cores.
[    6.567257] vboxdrv: fAsync=3D0 offMin=3D0x3ea offMax=3D0x2588
[    6.567395] vboxdrv: TSC mode is 'synchronous', kernel timer mode is 'no=
rmal'.
[    6.567397] vboxdrv: Successfully loaded version 4.3.20_OSE (interface 0=
x001a0008).
[    6.568897] EXT4-fs (sda5): re-mounted. Opts: (null)
[    9.856787] ACPI: Battery Slot [BAT0] (battery present)
[    9.909078] agpgart: Erk, registering with no pci_dev!
[    9.909083] agpgart-intel: probe of 0000:00:00.0 failed with error -22
[    9.923847] tpm_tis 00:05: 1.2 TPM (device-id 0x0, rev-id 78)
[    9.927300] pps_core: LinuxPPS API ver. 1 registered
[    9.927302] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    9.941411] PTP clock support registered
[    9.972841] tpm_tis 00:05: TPM is disabled/deactivated (0x6)
[   10.045646] ACPI Warning: SystemIO range 0x00001028-0x0000102f conflicts=
 with OpRegion 0x00001000-0x0000107f (\_SB_.PCI0.LPC_.PMIO) (20140926/utadd=
ress-258)
[   10.045652] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   10.045656] ACPI Warning: SystemIO range 0x000011c0-0x000011cf conflicts=
 with OpRegion 0x00001180-0x000011ff (\_SB_.PCI0.LPC_.LPIO) (20140926/utadd=
ress-258)
[   10.045659] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   10.045660] ACPI Warning: SystemIO range 0x000011b0-0x000011bf conflicts=
 with OpRegion 0x00001180-0x000011ff (\_SB_.PCI0.LPC_.LPIO) (20140926/utadd=
ress-258)
[   10.045662] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   10.045663] ACPI Warning: SystemIO range 0x00001180-0x000011af conflicts=
 with OpRegion 0x00001180-0x000011ff (\_SB_.PCI0.LPC_.LPIO) (20140926/utadd=
ress-258)
[   10.045666] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   10.045667] lpc_ich: Resource conflict(s) found affecting gpio_ich
[   10.058335] thermal LNXTHERM:00: registered as thermal_zone0
[   10.058339] ACPI: Thermal Zone [THM0] (60 C)
[   10.068941] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   10.081236] i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
[   10.122734] intel ips 0000:00:1f.6: CPU TDP doesn't match expected value=
 (found 25, expected 29)
[   10.123420] wmi: Mapper loaded
[   10.126066] intel ips 0000:00:1f.6: IPS driver initialized, MCP temp lim=
it 90
[   10.134364] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[   10.134367] e1000e: Copyright(c) 1999 - 2014 Intel Corporation.
[   10.134526] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) se=
t to dynamic conservative mode
[   10.134548] e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
[   10.310987] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) f0:=
de:f1:08:57:de
[   10.310995] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connecti=
on
[   10.311040] e1000e 0000:00:19.0 eth0: MAC: 9, PHY: 10, PBA No: C5C0FF-0F=
F
[   10.311193] mei_me 0000:00:16.0: irq 27 for MSI/MSI-X
[   10.315956] ACPI: AC Adapter [AC] (on-line)
[   10.420470] cfg80211: Calling CRDA to update world regulatory domain
[   10.504483] Intel(R) Wireless WiFi driver for Linux, in-tree:
[   10.504486] Copyright(c) 2003- 2014 Intel Corporation
[   10.504652] iwlwifi 0000:02:00.0: can't disable ASPM; OS doesn't have AS=
PM control
[   10.504801] iwlwifi 0000:02:00.0: irq 28 for MSI/MSI-X
[   10.589711] Non-volatile memory driver v1.3
[   10.667220] iwlwifi 0000:02:00.0: Direct firmware load for iwlwifi-6000-=
6.ucode failed with error -2
[   10.667255] iwlwifi 0000:02:00.0: Direct firmware load for iwlwifi-6000-=
5.ucode failed with error -2
[   10.679529] iwlwifi 0000:02:00.0: loaded firmware version 9.221.4.1 buil=
d 25532 op_mode iwldvm
[   10.819241] thinkpad_acpi: ThinkPad ACPI Extras v0.25
[   10.819245] thinkpad_acpi: http://ibm-acpi.sf.net/
[   10.819246] thinkpad_acpi: ThinkPad BIOS 6QET46WW (1.16 ), EC 6QHT28WW-1=
.09
[   10.819248] thinkpad_acpi: Lenovo ThinkPad X201, model 3680BR4
[   10.819694] thinkpad_acpi: detected a 16-level brightness capable ThinkP=
ad
[   10.819868] thinkpad_acpi: radio switch found; radios are enabled
[   10.820047] thinkpad_acpi: possible tablet mode switch found; ThinkPad i=
n laptop mode
[   10.820059] thinkpad_acpi: This ThinkPad has standard ACPI backlight bri=
ghtness control, supported by the ACPI video driver
[   10.820060] thinkpad_acpi: Disabling thinkpad-acpi brightness events by =
default...
[   10.823954] thinkpad_acpi: Standard ACPI backlight interface available, =
not loading native one
[   10.824030] thinkpad_acpi: Console audio control enabled, mode: override=
 (read/write)
[   10.825218] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_=
acpi/input/input9
[   10.848234] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUG disabled
[   10.848238] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUGFS disabled
[   10.848240] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEVICE_TRACING enabled
[   10.848242] iwlwifi 0000:02:00.0: Detected Intel(R) Centrino(R) Advanced=
-N 6200 AGN, REV=3D0x74
[   10.848392] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[   10.889301] ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
[   10.907788] iTCO_vendor_support: vendor-support=3D0
[   10.913764] snd_hda_intel 0000:00:1b.0: irq 29 for MSI/MSI-X
[   10.993037] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[   10.993085] iTCO_wdt: Found a QM57 TCO device (Version=3D2, TCOBASE=3D0x=
1060)
[   10.993158] iTCO_wdt: initialized. heartbeat=3D30 sec (nowayout=3D0)
[   11.048503] sound hdaudioC0D0: CX20585: BIOS auto-probing.
[   11.049003] sound hdaudioC0D0: autoconfig: line_outs=3D1 (0x1f/0x0/0x0/0=
x0/0x0) type:speaker
[   11.049006] sound hdaudioC0D0:    speaker_outs=3D0 (0x0/0x0/0x0/0x0/0x0)
[   11.049007] sound hdaudioC0D0:    hp_outs=3D2 (0x1c/0x19/0x0/0x0/0x0)
[   11.049009] sound hdaudioC0D0:    mono: mono_out=3D0x0
[   11.049010] sound hdaudioC0D0:    inputs:
[   11.049012] sound hdaudioC0D0:      Internal Mic=3D0x23
[   11.049014] sound hdaudioC0D0:      Mic=3D0x1b
[   11.049015] sound hdaudioC0D0:      Dock Mic=3D0x1a
[   11.050092] sound hdaudioC0D0: Enable sync_write for stable communicatio=
n
[   11.247477] psmouse serio1: synaptics: Touchpad model: 1, fw: 7.4, id: 0=
x1e0b1, caps: 0xd047b3/0xb40000/0xa0000, board id: 71, fw id: 615624
[   11.247490] psmouse serio1: synaptics: serio: Synaptics pass-through por=
t at isa0060/serio1/input0
[   11.300794] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042=
/serio1/input/input8
[   11.325149] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.=
0/sound/card0/hdaudioC0D0/input10
[   11.325557] input: HDA Intel MID Mic as /devices/pci0000:00/0000:00:1b.0=
/sound/card0/input12
[   11.325647] input: HDA Intel MID Dock Mic as /devices/pci0000:00/0000:00=
:1b.0/sound/card0/input13
[   11.325734] input: HDA Intel MID Dock Headphone as /devices/pci0000:00/0=
000:00:1b.0/sound/card0/input14
[   11.325815] input: HDA Intel MID Headphone as /devices/pci0000:00/0000:0=
0:1b.0/sound/card0/input15
[   11.325899] input: HDA Intel MID HDMI/DP,pcm=3D3 as /devices/pci0000:00/=
0000:00:1b.0/sound/card0/input16
[   11.430883] mousedev: PS/2 mouse device common for all mice
[   11.718985] kvm: disabled by bios
[   11.735951] kvm: disabled by bios
[   12.032924] systemd-journald[144]: Received request to flush runtime jou=
rnal from PID 1
[   13.513457] Adding 249000k swap on /dev/sda2.  Priority:-1 extents:1 acr=
oss:249000k FS
[   14.084971] EXT4-fs (sda1): mounting ext2 file system using the ext4 sub=
system
[   14.254685] EXT4-fs (sda1): mounted filesystem without journal. Opts: (n=
ull)
[   14.919322] Bluetooth: Core ver 2.19
[   14.919341] NET: Registered protocol family 31
[   14.919342] Bluetooth: HCI device and connection manager initialized
[   14.919350] Bluetooth: HCI socket layer initialized
[   14.919353] Bluetooth: L2CAP socket layer initialized
[   14.919359] Bluetooth: SCO socket layer initialized
[   14.976084] usbcore: registered new interface driver btusb
[   15.236769] EXT4-fs (sda6): mounted filesystem with ordered data mode. O=
pts: (null)
[   15.285941] psmouse serio2: hgpk: ID: 10 00 64
[   16.923655] psmouse serio2: trackpoint: IBM TrackPoint firmware: 0x0e, b=
uttons: 3/3
[   17.188937] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/seri=
o1/serio2/input/input11
[   19.248504] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   19.248508] Bluetooth: BNEP filters: protocol multicast
[   19.248514] Bluetooth: BNEP socket layer initialized
[   22.488952] e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
[   22.589181] e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
[   22.589351] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   24.021487] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[   24.028356] iwlwifi 0000:02:00.0: Radio type=3D0x1-0x3-0x1
[   24.238338] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[   24.245153] iwlwifi 0000:02:00.0: Radio type=3D0x1-0x3-0x1
[   24.320319] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   26.332454] wlan0: authenticate with 00:25:9c:3d:11:92
[   26.333774] wlan0: send auth to 00:25:9c:3d:11:92 (try 1/3)
[   26.339122] wlan0: authenticated
[   26.339351] iwlwifi 0000:02:00.0 wlan0: disabling HT/VHT due to WEP/TKIP=
 use
[   26.339360] wlan0: waiting for beacon from 00:25:9c:3d:11:92
[   26.413651] wlan0: associate with 00:25:9c:3d:11:92 (try 1/3)
[   26.417375] wlan0: RX AssocResp from 00:25:9c:3d:11:92 (capab=3D0x411 st=
atus=3D0 aid=3D2)
[   26.427487] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   26.427671] wlan0: associated
[   54.181665] cfg80211: Calling CRDA to update world regulatory domain
[   90.496163] cfg80211: Calling CRDA to update world regulatory domain
[  124.726421] fuse init (API version 7.23)
[  163.182366] cfg80211: Calling CRDA to update world regulatory domain
[  549.484387] perf interrupt took too long (2523 > 2495), lowering kernel.=
perf_event_max_sample_rate to 50100
[ 1207.499667] perf interrupt took too long (4991 > 4960), lowering kernel.=
perf_event_max_sample_rate to 25200
[ 1536.295554] iwlwifi 0000:02:00.0: Error sending REPLY_TXFIFO_FLUSH: time=
 out after 2000ms.
[ 1536.295561] iwlwifi 0000:02:00.0: Current CMD queue read_ptr 222 write_p=
tr 226
[ 1536.312697] ------------[ cut here ]------------
[ 1536.312716] WARNING: CPU: 0 PID: 2530 at drivers/net/wireless/iwlwifi/pc=
ie/trans.c:1269 iwl_trans_pcie_grab_nic_access+0x294/0x2a0 [iwlwifi]()
[ 1536.312718] Timeout waiting for hardware access (CSR_GP_CNTRL 0xffffffff=
)
[ 1536.312720] Modules linked in: fuse bnep btusb bluetooth coretemp intel_=
powerclamp joydev mousedev kvm snd_hda_codec_hdmi crc32_pclmul crc32c_intel=
 snd_hda_codec_conexant snd_hda_codec_generic aesni_intel iTCO_wdt snd_hda_=
intel iTCO_vendor_support aes_i586 snd_hda_controller arc4 iwldvm thinkpad_=
acpi xts snd_hda_codec mac80211 lrw nvram iwlwifi snd_hwdep snd_pcm cfg8021=
1 gf128mul snd_timer ablk_helper led_class snd hwmon ac rfkill psmouse cryp=
td soundcore mei_me mei serio_raw e1000e wmi intel_ips i2c_i801 shpchp ther=
mal lpc_ich ptp pps_core tpm_tis intel_agp tpm battery evdev mac_hid sch_fq=
_codel cpufreq_powersave acpi_cpufreq processor vboxnetflt(O) vboxdrv(O) tp=
_smapi(O) thinkpad_ec(O) ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid =
hid atkbd libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd
[ 1536.312771]  usbcore usb_common i8042 serio i915 button intel_gtt i2c_al=
go_bit video drm_kms_helper drm agpgart i2c_core
[ 1536.312783] CPU: 0 PID: 2530 Comm: kworker/u8:1 Tainted: G           O  =
 3.18.2-2-ARCH #1
[ 1536.312785] Hardware name: LENOVO 3680BR4/3680BR4, BIOS 6QET46WW (1.16 )=
 06/07/2010
[ 1536.312801] Workqueue: phy0 ieee80211_beacon_connection_loss_work [mac80=
211]
[ 1536.312803]  00000000 9454c866 00000000 ce1b1cbc c1474f33 ce1b1d00 ce1b1=
cf0 c10527f2
[ 1536.312808]  f84405d0 ce1b1d20 000009e2 f84405a4 000004f5 f8430f34 00000=
4f5 f8430f34
[ 1536.312812]  f843ba80 ce1b1d58 f43aa000 ce1b1d0c c105284e 00000009 ce1b1=
d00 f84405d0
[ 1536.312816] Call Trace:
[ 1536.312825]  [<c1474f33>] dump_stack+0x48/0x69
[ 1536.312832]  [<c10527f2>] warn_slowpath_common+0x82/0xa0
[ 1536.312837]  [<f8430f34>] ? iwl_trans_pcie_grab_nic_access+0x294/0x2a0 [=
iwlwifi]
[ 1536.312840]  [<f8430f34>] ? iwl_trans_pcie_grab_nic_access+0x294/0x2a0 [=
iwlwifi]
[ 1536.312843]  [<c105284e>] warn_slowpath_fmt+0x3e/0x60
[ 1536.312847]  [<f8430f34>] iwl_trans_pcie_grab_nic_access+0x294/0x2a0 [iw=
lwifi]
[ 1536.312852]  [<f842447c>] iwl_write_prph+0x2c/0x60 [iwlwifi]
[ 1536.312856]  [<f84244d6>] iwl_force_nmi+0x26/0x50 [iwlwifi]
[ 1536.312860]  [<f842fcc0>] iwl_trans_pcie_send_hcmd+0x5a0/0x620 [iwlwifi]
[ 1536.312865]  [<c108ad20>] ? __wake_up_sync+0x20/0x20
[ 1536.312872]  [<f89486b1>] iwl_dvm_send_cmd+0x51/0x150 [iwldvm]
[ 1536.312876]  [<f8948863>] iwlagn_txfifo_flush+0xb3/0xe0 [iwldvm]
[ 1536.312880]  [<f89420d7>] iwlagn_mac_flush+0xc7/0x200 [iwldvm]
[ 1536.312884]  [<f8942010>] ? iwlagn_mac_conf_tx+0x1a0/0x1a0 [iwldvm]
[ 1536.312894]  [<f91d007a>] ieee80211_flush_queues+0x8a/0x1a0 [mac80211]
[ 1536.312904]  [<f91e6b3a>] ieee80211_mgd_probe_ap_send+0x9a/0x150 [mac802=
11]
[ 1536.312913]  [<f91e6706>] ? ieee80211_recalc_ps.part.19+0xb6/0x1f0 [mac8=
0211]
[ 1536.312924]  [<f91e6cda>] ieee80211_mgd_probe_ap.part.20+0xea/0x120 [mac=
80211]
[ 1536.312934]  [<f91e72d7>] ieee80211_beacon_connection_loss_work+0x57/0x9=
0 [mac80211]
[ 1536.312939]  [<c1067580>] ? pwq_dec_nr_in_flight+0x40/0x90
[ 1536.312942]  [<c1067a63>] process_one_work+0x113/0x380
[ 1536.312945]  [<c147007b>] ? netlbl_cipsov4_remove+0x2b/0xc0
[ 1536.312948]  [<c1067f59>] worker_thread+0x39/0x440
[ 1536.312951]  [<c1067f20>] ? init_pwq.part.30+0x10/0x10
[ 1536.312954]  [<c106c173>] kthread+0xb3/0xd0
[ 1536.312958]  [<c1479bc1>] ret_from_kernel_thread+0x21/0x30
[ 1536.312960]  [<c106c0c0>] ? kthread_create_on_node+0x130/0x130
[ 1536.312963] ---[ end trace a5b5252fd3fa22c1 ]---
[ 1536.312993] iwlwifi 0000:02:00.0: Loaded firmware version: 9.221.4.1 bui=
ld 25532
[ 1536.330191] iwlwifi 0000:02:00.0: Start IWL Error Log Dump:
[ 1536.330198] iwlwifi 0000:02:00.0: Status: 0x0000004C, count: -197484544
[ 1536.330201] iwlwifi 0000:02:00.0: 0xCE1B1CBC | ADVANCED_SYSASSERT       =
  =20
[ 1536.330202] iwlwifi 0000:02:00.0: 0xC10564D3 | uPc
[ 1536.330204] iwlwifi 0000:02:00.0: 0xCE1B1CC8 | branchlink1
[ 1536.330206] iwlwifi 0000:02:00.0: 0xC147AD98 | branchlink2
[ 1536.330208] iwlwifi 0000:02:00.0: 0x9454C866 | interruptlink1
[ 1536.330210] iwlwifi 0000:02:00.0: 0xF5303B20 | interruptlink2
[ 1536.330212] iwlwifi 0000:02:00.0: 0xC1538797 | data1
[ 1536.330213] iwlwifi 0000:02:00.0: 0xCE1B1E08 | data2
[ 1536.330216] iwlwifi 0000:02:00.0: 0xCE1B1CE0 | line
[ 1536.330217] iwlwifi 0000:02:00.0: 0xC131754F | beacon time
[ 1536.330219] iwlwifi 0000:02:00.0: 0xCE1B1CF4 | tsf low
[ 1536.330221] iwlwifi 0000:02:00.0: 0xCE1B1D10 | tsf hi
[ 1536.330223] iwlwifi 0000:02:00.0: 0xC13175AA | time gp1
[ 1536.330224] iwlwifi 0000:02:00.0: 0x00000003 | time gp2
[ 1536.330226] iwlwifi 0000:02:00.0: 0xF533E064 | time gp3
[ 1536.330228] iwlwifi 0000:02:00.0: 0xC156A6F8 | uCode version
[ 1536.330230] iwlwifi 0000:02:00.0: 0xF843E569 | hw version
[ 1536.330231] iwlwifi 0000:02:00.0: 0xF5303B20 | board version
[ 1536.330233] iwlwifi 0000:02:00.0: 0xF2C49084 | hcmd
[ 1536.330235] iwlwifi 0000:02:00.0: 0xCE1B1D40 | isr0
[ 1536.330237] iwlwifi 0000:02:00.0: 0xCE1B1D28 | isr1
[ 1536.330239] iwlwifi 0000:02:00.0: 0xC1317768 | isr2
[ 1536.330241] iwlwifi 0000:02:00.0: 0xCE1B1D38 | isr3
[ 1536.330242] iwlwifi 0000:02:00.0: 0xF843E2DA | isr4
[ 1536.330244] iwlwifi 0000:02:00.0: 0xCE1B1D18 | isr_pref
[ 1536.330246] iwlwifi 0000:02:00.0: 0x9454C866 | wait_event
[ 1536.330248] iwlwifi 0000:02:00.0: 0xCE1B1D54 | l2p_control
[ 1536.330250] iwlwifi 0000:02:00.0: 0xF8426340 | l2p_duration
[ 1536.330252] iwlwifi 0000:02:00.0: 0xF533E064 | l2p_mhvalid
[ 1536.330253] iwlwifi 0000:02:00.0: 0xF843E2DA | l2p_addr_match
[ 1536.330255] iwlwifi 0000:02:00.0: 0xCE1B1D40 | lmpm_pmg_sel
[ 1536.330256] iwlwifi 0000:02:00.0: 0xCE1B1D6C | timestamp
[ 1536.330258] iwlwifi 0000:02:00.0: 0xF895A0B1 | flow_handler
[ 1536.347419] ------------[ cut here ]------------
[ 1536.347434] WARNING: CPU: 0 PID: 2530 at drivers/net/wireless/iwlwifi/dv=
m/../iwl-trans.h:891 iwl_dump_nic_event_log+0x397/0x3b0 [iwldvm]()
[ 1536.347436] Modules linked in: fuse bnep btusb bluetooth coretemp intel_=
powerclamp joydev mousedev kvm snd_hda_codec_hdmi crc32_pclmul crc32c_intel=
 snd_hda_codec_conexant snd_hda_codec_generic aesni_intel iTCO_wdt snd_hda_=
intel iTCO_vendor_support aes_i586 snd_hda_controller arc4 iwldvm thinkpad_=
acpi xts snd_hda_codec mac80211 lrw nvram iwlwifi snd_hwdep snd_pcm cfg8021=
1 gf128mul snd_timer ablk_helper led_class snd hwmon ac rfkill psmouse cryp=
td soundcore mei_me mei serio_raw e1000e wmi intel_ips i2c_i801 shpchp ther=
mal lpc_ich ptp pps_core tpm_tis intel_agp tpm battery evdev mac_hid sch_fq=
_codel cpufreq_powersave acpi_cpufreq processor vboxnetflt(O) vboxdrv(O) tp=
_smapi(O) thinkpad_ec(O) ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid =
hid atkbd libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd
[ 1536.347476]  usbcore usb_common i8042 serio i915 button intel_gtt i2c_al=
go_bit video drm_kms_helper drm agpgart i2c_core
[ 1536.347486] CPU: 0 PID: 2530 Comm: kworker/u8:1 Tainted: G        W  O  =
 3.18.2-2-ARCH #1
[ 1536.347487] Hardware name: LENOVO 3680BR4/3680BR4, BIOS 6QET46WW (1.16 )=
 06/07/2010
[ 1536.347499] Workqueue: phy0 ieee80211_beacon_connection_loss_work [mac80=
211]
[ 1536.347501]  00000000 9454c866 00000000 ce1b1cc0 c1474f33 00000000 ce1b1=
cf4 c10527f2
[ 1536.347504]  c15468cc 00000000 000009e2 f895c488 0000037b f893c867 00000=
37b f893c867
[ 1536.347507]  00800914 f2c49084 f843ba80 ce1b1d04 c10528e2 00000009 00000=
000 ce1b1d54
[ 1536.347510] Call Trace:
[ 1536.347520]  [<c1474f33>] dump_stack+0x48/0x69
[ 1536.347526]  [<c10527f2>] warn_slowpath_common+0x82/0xa0
[ 1536.347530]  [<f893c867>] ? iwl_dump_nic_event_log+0x397/0x3b0 [iwldvm]
[ 1536.347533]  [<f893c867>] ? iwl_dump_nic_event_log+0x397/0x3b0 [iwldvm]
[ 1536.347536]  [<c10528e2>] warn_slowpath_null+0x22/0x30
[ 1536.347539]  [<f893c867>] iwl_dump_nic_event_log+0x397/0x3b0 [iwldvm]
[ 1536.347544]  [<c1317768>] ? dev_err+0x38/0x50
[ 1536.347548]  [<f8426340>] ? __iwl_err+0xd0/0xe0 [iwlwifi]
[ 1536.347551]  [<f893c8ce>] iwl_nic_error+0x4e/0x60 [iwldvm]
[ 1536.347555]  [<f842fcdc>] iwl_trans_pcie_send_hcmd+0x5bc/0x620 [iwlwifi]
[ 1536.347560]  [<c108ad20>] ? __wake_up_sync+0x20/0x20
[ 1536.347565]  [<f89486b1>] iwl_dvm_send_cmd+0x51/0x150 [iwldvm]
[ 1536.347569]  [<f8948863>] iwlagn_txfifo_flush+0xb3/0xe0 [iwldvm]
[ 1536.347573]  [<f89420d7>] iwlagn_mac_flush+0xc7/0x200 [iwldvm]
[ 1536.347576]  [<f8942010>] ? iwlagn_mac_conf_tx+0x1a0/0x1a0 [iwldvm]
[ 1536.347584]  [<f91d007a>] ieee80211_flush_queues+0x8a/0x1a0 [mac80211]
[ 1536.347592]  [<f91e6b3a>] ieee80211_mgd_probe_ap_send+0x9a/0x150 [mac802=
11]
[ 1536.347600]  [<f91e6706>] ? ieee80211_recalc_ps.part.19+0xb6/0x1f0 [mac8=
0211]
[ 1536.347607]  [<f91e6cda>] ieee80211_mgd_probe_ap.part.20+0xea/0x120 [mac=
80211]
[ 1536.347615]  [<f91e72d7>] ieee80211_beacon_connection_loss_work+0x57/0x9=
0 [mac80211]
[ 1536.347619]  [<c1067580>] ? pwq_dec_nr_in_flight+0x40/0x90
[ 1536.347621]  [<c1067a63>] process_one_work+0x113/0x380
[ 1536.347623]  [<c147007b>] ? netlbl_cipsov4_remove+0x2b/0xc0
[ 1536.347625]  [<c1067f59>] worker_thread+0x39/0x440
[ 1536.347627]  [<c1067f20>] ? init_pwq.part.30+0x10/0x10
[ 1536.347629]  [<c106c173>] kthread+0xb3/0xd0
[ 1536.347632]  [<c1479bc1>] ret_from_kernel_thread+0x21/0x30
[ 1536.347634]  [<c106c0c0>] ? kthread_create_on_node+0x130/0x130
[ 1536.347635] ---[ end trace a5b5252fd3fa22c2 ]---
[ 1536.364779] ------------[ cut here ]------------
[ 1536.364797] WARNING: CPU: 0 PID: 2530 at drivers/net/wireless/iwlwifi/dv=
m/../iwl-trans.h:891 iwl_dump_nic_event_log+0x357/0x3b0 [iwldvm]()
[ 1536.364798] Modules linked in: fuse bnep btusb bluetooth coretemp intel_=
powerclamp joydev mousedev kvm snd_hda_codec_hdmi crc32_pclmul crc32c_intel=
 snd_hda_codec_conexant snd_hda_codec_generic aesni_intel iTCO_wdt snd_hda_=
intel iTCO_vendor_support aes_i586 snd_hda_controller arc4 iwldvm thinkpad_=
acpi xts snd_hda_codec mac80211 lrw nvram iwlwifi snd_hwdep snd_pcm cfg8021=
1 gf128mul snd_timer ablk_helper led_class snd hwmon ac rfkill psmouse cryp=
td soundcore mei_me mei serio_raw e1000e wmi intel_ips i2c_i801 shpchp ther=
mal lpc_ich ptp pps_core tpm_tis intel_agp tpm battery evdev mac_hid sch_fq=
_codel cpufreq_powersave acpi_cpufreq processor vboxnetflt(O) vboxdrv(O) tp=
_smapi(O) thinkpad_ec(O) ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid =
hid atkbd libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd
[ 1536.364838]  usbcore usb_common i8042 serio i915 button intel_gtt i2c_al=
go_bit video drm_kms_helper drm agpgart i2c_core
[ 1536.364848] CPU: 0 PID: 2530 Comm: kworker/u8:1 Tainted: G        W  O  =
 3.18.2-2-ARCH #1
[ 1536.364850] Hardware name: LENOVO 3680BR4/3680BR4, BIOS 6QET46WW (1.16 )=
 06/07/2010
[ 1536.364862] Workqueue: phy0 ieee80211_beacon_connection_loss_work [mac80=
211]
[ 1536.364864]  00000000 9454c866 00000000 ce1b1cc0 c1474f33 00000000 ce1b1=
cf4 c10527f2
[ 1536.364867]  c15468cc 00000000 000009e2 f895c488 0000037b f893c827 00000=
37b f893c827
[ 1536.364870]  00800914 f2c49084 f843ba80 ce1b1d04 c10528e2 00000009 00000=
000 ce1b1d54
[ 1536.364874] Call Trace:
[ 1536.364882]  [<c1474f33>] dump_stack+0x48/0x69
[ 1536.364887]  [<c10527f2>] warn_slowpath_common+0x82/0xa0
[ 1536.364891]  [<f893c827>] ? iwl_dump_nic_event_log+0x357/0x3b0 [iwldvm]
[ 1536.364894]  [<f893c827>] ? iwl_dump_nic_event_log+0x357/0x3b0 [iwldvm]
[ 1536.364897]  [<c10528e2>] warn_slowpath_null+0x22/0x30
[ 1536.364900]  [<f893c827>] iwl_dump_nic_event_log+0x357/0x3b0 [iwldvm]
[ 1536.364904]  [<c1317768>] ? dev_err+0x38/0x50
[ 1536.364908]  [<f893c8ce>] iwl_nic_error+0x4e/0x60 [iwldvm]
[ 1536.364912]  [<f842fcdc>] iwl_trans_pcie_send_hcmd+0x5bc/0x620 [iwlwifi]
[ 1536.364917]  [<c108ad20>] ? __wake_up_sync+0x20/0x20
[ 1536.364922]  [<f89486b1>] iwl_dvm_send_cmd+0x51/0x150 [iwldvm]
[ 1536.364926]  [<f8948863>] iwlagn_txfifo_flush+0xb3/0xe0 [iwldvm]
[ 1536.364929]  [<f89420d7>] iwlagn_mac_flush+0xc7/0x200 [iwldvm]
[ 1536.364933]  [<f8942010>] ? iwlagn_mac_conf_tx+0x1a0/0x1a0 [iwldvm]
[ 1536.364941]  [<f91d007a>] ieee80211_flush_queues+0x8a/0x1a0 [mac80211]
[ 1536.364949]  [<f91e6b3a>] ieee80211_mgd_probe_ap_send+0x9a/0x150 [mac802=
11]
[ 1536.364956]  [<f91e6706>] ? ieee80211_recalc_ps.part.19+0xb6/0x1f0 [mac8=
0211]
[ 1536.364964]  [<f91e6cda>] ieee80211_mgd_probe_ap.part.20+0xea/0x120 [mac=
80211]
[ 1536.364972]  [<f91e72d7>] ieee80211_beacon_connection_loss_work+0x57/0x9=
0 [mac80211]
[ 1536.364975]  [<c1067580>] ? pwq_dec_nr_in_flight+0x40/0x90
[ 1536.364977]  [<c1067a63>] process_one_work+0x113/0x380
[ 1536.364979]  [<c147007b>] ? netlbl_cipsov4_remove+0x2b/0xc0
[ 1536.364981]  [<c1067f59>] worker_thread+0x39/0x440
[ 1536.364983]  [<c1067f20>] ? init_pwq.part.30+0x10/0x10
[ 1536.364985]  [<c106c173>] kthread+0xb3/0xd0
[ 1536.364988]  [<c1479bc1>] ret_from_kernel_thread+0x21/0x30
[ 1536.364989]  [<c106c0c0>] ? kthread_create_on_node+0x130/0x130
[ 1536.364991] ---[ end trace a5b5252fd3fa22c3 ]---
[ 1536.382167] ------------[ cut here ]------------
[ 1536.382186] WARNING: CPU: 0 PID: 2530 at drivers/net/wireless/iwlwifi/dv=
m/../iwl-trans.h:891 iwl_dump_nic_event_log+0x377/0x3b0 [iwldvm]()
[ 1536.382187] Modules linked in: fuse bnep btusb bluetooth coretemp intel_=
powerclamp joydev mousedev kvm snd_hda_codec_hdmi crc32_pclmul crc32c_intel=
 snd_hda_codec_conexant snd_hda_codec_generic aesni_intel iTCO_wdt snd_hda_=
intel iTCO_vendor_support aes_i586 snd_hda_controller arc4 iwldvm thinkpad_=
acpi xts snd_hda_codec mac80211 lrw nvram iwlwifi snd_hwdep snd_pcm cfg8021=
1 gf128mul snd_timer ablk_helper led_class snd hwmon ac rfkill psmouse cryp=
td soundcore mei_me mei serio_raw e1000e wmi intel_ips i2c_i801 shpchp ther=
mal lpc_ich ptp pps_core tpm_tis intel_agp tpm battery evdev mac_hid sch_fq=
_codel cpufreq_powersave acpi_cpufreq processor vboxnetflt(O) vboxdrv(O) tp=
_smapi(O) thinkpad_ec(O) ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid =
hid atkbd libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd
[ 1536.382227]  usbcore usb_common i8042 serio i915 button intel_gtt i2c_al=
go_bit video drm_kms_helper drm agpgart i2c_core
[ 1536.382237] CPU: 0 PID: 2530 Comm: kworker/u8:1 Tainted: G        W  O  =
 3.18.2-2-ARCH #1
[ 1536.382239] Hardware name: LENOVO 3680BR4/3680BR4, BIOS 6QET46WW (1.16 )=
 06/07/2010
[ 1536.382251] Workqueue: phy0 ieee80211_beacon_connection_loss_work [mac80=
211]
[ 1536.382253]  00000000 9454c866 00000000 ce1b1cc0 c1474f33 00000000 ce1b1=
cf4 c10527f2
[ 1536.382256]  c15468cc 00000000 000009e2 f895c488 0000037b f893c847 00000=
37b f893c847
[ 1536.382259]  00800914 f2c49084 f843ba80 ce1b1d04 c10528e2 00000009 00000=
000 ce1b1d54
[ 1536.382263] Call Trace:
[ 1536.382271]  [<c1474f33>] dump_stack+0x48/0x69
[ 1536.382277]  [<c10527f2>] warn_slowpath_common+0x82/0xa0
[ 1536.382281]  [<f893c847>] ? iwl_dump_nic_event_log+0x377/0x3b0 [iwldvm]
[ 1536.382284]  [<f893c847>] ? iwl_dump_nic_event_log+0x377/0x3b0 [iwldvm]
[ 1536.382286]  [<c10528e2>] warn_slowpath_null+0x22/0x30
[ 1536.382289]  [<f893c847>] iwl_dump_nic_event_log+0x377/0x3b0 [iwldvm]
[ 1536.382294]  [<c1317768>] ? dev_err+0x38/0x50
[ 1536.382298]  [<f893c8ce>] iwl_nic_error+0x4e/0x60 [iwldvm]
[ 1536.382303]  [<f842fcdc>] iwl_trans_pcie_send_hcmd+0x5bc/0x620 [iwlwifi]
[ 1536.382307]  [<c108ad20>] ? __wake_up_sync+0x20/0x20
[ 1536.382312]  [<f89486b1>] iwl_dvm_send_cmd+0x51/0x150 [iwldvm]
[ 1536.382316]  [<f8948863>] iwlagn_txfifo_flush+0xb3/0xe0 [iwldvm]
[ 1536.382319]  [<f89420d7>] iwlagn_mac_flush+0xc7/0x200 [iwldvm]
[ 1536.382323]  [<f8942010>] ? iwlagn_mac_conf_tx+0x1a0/0x1a0 [iwldvm]
[ 1536.382331]  [<f91d007a>] ieee80211_flush_queues+0x8a/0x1a0 [mac80211]
[ 1536.382339]  [<f91e6b3a>] ieee80211_mgd_probe_ap_send+0x9a/0x150 [mac802=
11]
[ 1536.382346]  [<f91e6706>] ? ieee80211_recalc_ps.part.19+0xb6/0x1f0 [mac8=
0211]
[ 1536.382354]  [<f91e6cda>] ieee80211_mgd_probe_ap.part.20+0xea/0x120 [mac=
80211]
[ 1536.382362]  [<f91e72d7>] ieee80211_beacon_connection_loss_work+0x57/0x9=
0 [mac80211]
[ 1536.382365]  [<c1067580>] ? pwq_dec_nr_in_flight+0x40/0x90
[ 1536.382367]  [<c1067a63>] process_one_work+0x113/0x380
[ 1536.382369]  [<c147007b>] ? netlbl_cipsov4_remove+0x2b/0xc0
[ 1536.382371]  [<c1067f59>] worker_thread+0x39/0x440
[ 1536.382373]  [<c1067f20>] ? init_pwq.part.30+0x10/0x10
[ 1536.382375]  [<c106c173>] kthread+0xb3/0xd0
[ 1536.382378]  [<c1479bc1>] ret_from_kernel_thread+0x21/0x30
[ 1536.382380]  [<c106c0c0>] ? kthread_create_on_node+0x130/0x130
[ 1536.382382] ---[ end trace a5b5252fd3fa22c4 ]---
[ 1536.399578] ------------[ cut here ]------------
[ 1536.399596] WARNING: CPU: 0 PID: 2530 at drivers/net/wireless/iwlwifi/dv=
m/../iwl-trans.h:891 iwl_dump_nic_event_log+0x33c/0x3b0 [iwldvm]()
[ 1536.399598] Modules linked in: fuse bnep btusb bluetooth coretemp intel_=
powerclamp joydev mousedev kvm snd_hda_codec_hdmi crc32_pclmul crc32c_intel=
 snd_hda_codec_conexant snd_hda_codec_generic aesni_intel iTCO_wdt snd_hda_=
intel iTCO_vendor_support aes_i586 snd_hda_controller arc4 iwldvm thinkpad_=
acpi xts snd_hda_codec mac80211 lrw nvram iwlwifi snd_hwdep snd_pcm cfg8021=
1 gf128mul snd_timer ablk_helper led_class snd hwmon ac rfkill psmouse cryp=
td soundcore mei_me mei serio_raw e1000e wmi intel_ips i2c_i801 shpchp ther=
mal lpc_ich ptp pps_core tpm_tis intel_agp tpm battery evdev mac_hid sch_fq=
_codel cpufreq_powersave acpi_cpufreq processor vboxnetflt(O) vboxdrv(O) tp=
_smapi(O) thinkpad_ec(O) ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid =
hid atkbd libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd
[ 1536.399638]  usbcore usb_common i8042 serio i915 button intel_gtt i2c_al=
go_bit video drm_kms_helper drm agpgart i2c_core
[ 1536.399648] CPU: 0 PID: 2530 Comm: kworker/u8:1 Tainted: G        W  O  =
 3.18.2-2-ARCH #1
[ 1536.399649] Hardware name: LENOVO 3680BR4/3680BR4, BIOS 6QET46WW (1.16 )=
 06/07/2010
[ 1536.399662] Workqueue: phy0 ieee80211_beacon_connection_loss_work [mac80=
211]
[ 1536.399664]  00000000 9454c866 00000000 ce1b1cc0 c1474f33 00000000 ce1b1=
cf4 c10527f2
[ 1536.399667]  c15468cc 00000000 000009e2 f895c488 0000037b f893c80c 00000=
37b f893c80c
[ 1536.399670]  a5a5a5a5 f2c49084 f843ba80 ce1b1d04 c10528e2 00000009 00000=
000 ce1b1d54
[ 1536.399673] Call Trace:
[ 1536.399681]  [<c1474f33>] dump_stack+0x48/0x69
[ 1536.399686]  [<c10527f2>] warn_slowpath_common+0x82/0xa0
[ 1536.399690]  [<f893c80c>] ? iwl_dump_nic_event_log+0x33c/0x3b0 [iwldvm]
[ 1536.399693]  [<f893c80c>] ? iwl_dump_nic_event_log+0x33c/0x3b0 [iwldvm]
[ 1536.399695]  [<c10528e2>] warn_slowpath_null+0x22/0x30
[ 1536.399698]  [<f893c80c>] iwl_dump_nic_event_log+0x33c/0x3b0 [iwldvm]
[ 1536.399703]  [<c1317768>] ? dev_err+0x38/0x50
[ 1536.399707]  [<f893c8ce>] iwl_nic_error+0x4e/0x60 [iwldvm]
[ 1536.399712]  [<f842fcdc>] iwl_trans_pcie_send_hcmd+0x5bc/0x620 [iwlwifi]
[ 1536.399716]  [<c108ad20>] ? __wake_up_sync+0x20/0x20
[ 1536.399721]  [<f89486b1>] iwl_dvm_send_cmd+0x51/0x150 [iwldvm]
[ 1536.399725]  [<f8948863>] iwlagn_txfifo_flush+0xb3/0xe0 [iwldvm]
[ 1536.399729]  [<f89420d7>] iwlagn_mac_flush+0xc7/0x200 [iwldvm]
[ 1536.399732]  [<f8942010>] ? iwlagn_mac_conf_tx+0x1a0/0x1a0 [iwldvm]
[ 1536.399741]  [<f91d007a>] ieee80211_flush_queues+0x8a/0x1a0 [mac80211]
[ 1536.399749]  [<f91e6b3a>] ieee80211_mgd_probe_ap_send+0x9a/0x150 [mac802=
11]
[ 1536.399756]  [<f91e6706>] ? ieee80211_recalc_ps.part.19+0xb6/0x1f0 [mac8=
0211]
[ 1536.399764]  [<f91e6cda>] ieee80211_mgd_probe_ap.part.20+0xea/0x120 [mac=
80211]
[ 1536.399771]  [<f91e72d7>] ieee80211_beacon_connection_loss_work+0x57/0x9=
0 [mac80211]
[ 1536.399775]  [<c1067580>] ? pwq_dec_nr_in_flight+0x40/0x90
[ 1536.399777]  [<c1067a63>] process_one_work+0x113/0x380
[ 1536.399780]  [<c147007b>] ? netlbl_cipsov4_remove+0x2b/0xc0
[ 1536.399782]  [<c1067f59>] worker_thread+0x39/0x440
[ 1536.399784]  [<c1067f20>] ? init_pwq.part.30+0x10/0x10
[ 1536.399786]  [<c106c173>] kthread+0xb3/0xd0
[ 1536.399789]  [<c1479bc1>] ret_from_kernel_thread+0x21/0x30
[ 1536.399791]  [<c106c0c0>] ? kthread_create_on_node+0x130/0x130
[ 1536.399792] ---[ end trace a5b5252fd3fa22c5 ]---
[ 1536.399797] iwlwifi 0000:02:00.0: Log capacity -1515870811 is bogus, lim=
it to 512 entries
[ 1536.399800] iwlwifi 0000:02:00.0: Log write index -1515870811 is bogus, =
limit to 512
[ 1536.399802] iwlwifi 0000:02:00.0: Start IWL Event Log Dump: display last=
 20 entries
[ 1536.416951] iwlwifi 0000:02:00.0: flush request fail
[ 1538.194457] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 0 [0x5a5a5a5a]
[ 1539.990896] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 2 [0x5a5a5a5a]
[ 1541.827348] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 5 [0x5a5a5a5a]
[ 1543.625376] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 7 [0x5a5a5a5a]
[ 1545.380698] ieee80211 phy0: Hardware restart was requested
[ 1545.380786] iwlwifi 0000:02:00.0: Fw not loaded - dropping CMD: 1e
[ 1545.380791] iwlwifi 0000:02:00.0: flush request fail
[ 1545.397083] iwlwifi 0000:02:00.0: Fw not loaded - dropping CMD: 20
[ 1545.397095] wlan0: failed to remove key (0, ff:ff:ff:ff:ff:ff) from hard=
ware (-5)
[ 1545.397218] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[ 1545.466236] iwlwifi 0000:02:00.0: Radio type=3D0x1-0x3-0x1
[ 1551.100485] iwlwifi 0000:02:00.0: Failed to load firmware chunk!
[ 1551.100495] iwlwifi 0000:02:00.0: Could not load the [0] uCode section
[ 1551.100504] iwlwifi 0000:02:00.0: Failed to start RT ucode: -110
[ 1552.878783] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 0 [0x5a5a5a5a]
[ 1554.675102] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 2 [0x5a5a5a5a]
[ 1556.505200] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 5 [0x5a5a5a5a]
[ 1558.301091] iwlwifi 0000:02:00.0: Failing on timeout while stopping DMA =
channel 7 [0x5a5a5a5a]
[ 1558.301103] sched: RT throttling activated
[ 1560.060161] iwlwifi 0000:02:00.0: Unable to initialize device.
[ 1560.060170] ------------[ cut here ]------------
[ 1560.060197] WARNING: CPU: 2 PID: 149 at net/mac80211/util.c:1686 ieee802=
11_reconfig+0x12f2/0x16a0 [mac80211]()
[ 1560.060200] Hardware became unavailable during restart.
[ 1560.060202] Modules linked in: fuse bnep btusb bluetooth coretemp intel_=
powerclamp joydev mousedev kvm snd_hda_codec_hdmi crc32_pclmul crc32c_intel=
 snd_hda_codec_conexant snd_hda_codec_generic aesni_intel iTCO_wdt snd_hda_=
intel iTCO_vendor_support aes_i586 snd_hda_controller arc4 iwldvm thinkpad_=
acpi xts snd_hda_codec mac80211 lrw nvram iwlwifi snd_hwdep snd_pcm cfg8021=
1 gf128mul snd_timer ablk_helper led_class snd hwmon ac rfkill psmouse cryp=
td soundcore mei_me mei serio_raw e1000e wmi intel_ips i2c_i801 shpchp ther=
mal lpc_ich ptp pps_core tpm_tis intel_agp tpm battery evdev mac_hid sch_fq=
_codel cpufreq_powersave acpi_cpufreq processor vboxnetflt(O) vboxdrv(O) tp=
_smapi(O) thinkpad_ec(O) ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid =
hid atkbd libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd
[ 1560.060273]  usbcore usb_common i8042 serio i915 button intel_gtt i2c_al=
go_bit video drm_kms_helper drm agpgart i2c_core
[ 1560.060288] CPU: 2 PID: 149 Comm: kworker/2:2 Tainted: G        W  O   3=
.18.2-2-ARCH #1
[ 1560.060291] Hardware name: LENOVO 3680BR4/3680BR4, BIOS 6QET46WW (1.16 )=
 06/07/2010
[ 1560.060303] Workqueue: events ieee80211_restart_work [mac80211]
[ 1560.060305]  00000000 24cb9ba5 00000000 f4bf1e40 c1474f33 f4bf1e84 f4bf1=
e74 c10527f2
[ 1560.060312]  f920951c f4bf1ea4 00000095 f920b4e9 00000696 f91d2512 00000=
696 f91d2512
[ 1560.060318]  f2c48fe4 ffffff92 f4ad1900 f4bf1e90 c105284e 00000009 f4bf1=
e84 f920951c
[ 1560.060325] Call Trace:
[ 1560.060337]  [<c1474f33>] dump_stack+0x48/0x69
[ 1560.060345]  [<c10527f2>] warn_slowpath_common+0x82/0xa0
[ 1560.060362]  [<f91d2512>] ? ieee80211_reconfig+0x12f2/0x16a0 [mac80211]
[ 1560.060378]  [<f91d2512>] ? ieee80211_reconfig+0x12f2/0x16a0 [mac80211]
[ 1560.060383]  [<c105284e>] warn_slowpath_fmt+0x3e/0x60
[ 1560.060399]  [<f91d2512>] ieee80211_reconfig+0x12f2/0x16a0 [mac80211]
[ 1560.060404]  [<c1477bd4>] ? __mutex_lock_slowpath+0x34/0x120
[ 1560.060415]  [<f91a42ed>] ieee80211_restart_work+0x3d/0x80 [mac80211]
[ 1560.060421]  [<c1067580>] ? pwq_dec_nr_in_flight+0x40/0x90
[ 1560.060425]  [<c1067a63>] process_one_work+0x113/0x380
[ 1560.060429]  [<c14767d6>] ? preempt_schedule+0x36/0x50
[ 1560.060433]  [<c1067f59>] worker_thread+0x39/0x440
[ 1560.060437]  [<c1067f20>] ? init_pwq.part.30+0x10/0x10
[ 1560.060441]  [<c106c173>] kthread+0xb3/0xd0
[ 1560.060447]  [<c1479bc1>] ret_from_kernel_thread+0x21/0x30
[ 1560.060450]  [<c106c0c0>] ? kthread_create_on_node+0x130/0x130
[ 1560.060454] ---[ end trace a5b5252fd3fa22c6 ]---
[ 1560.060533] ------------[ cut here ]------------
[ 1560.060551] WARNING: CPU: 2 PID: 149 at net/mac80211/driver-ops.h:12 iee=
e80211_do_stop+0x872/0x890 [mac80211]()
[ 1560.060553] wlan0:  Failed check-sdata-in-driver check, flags: 0x4
[ 1560.060555] Modules linked in: fuse bnep btusb bluetooth coretemp intel_=
powerclamp joydev mousedev kvm snd_hda_codec_hdmi crc32_pclmul crc32c_intel=
 snd_hda_codec_conexant snd_hda_codec_generic aesni_intel iTCO_wdt snd_hda_=
intel iTCO_vendor_support aes_i586 snd_hda_controller arc4 iwldvm thinkpad_=
acpi xts snd_hda_codec mac80211 lrw nvram iwlwifi snd_hwdep snd_pcm cfg8021=
1 gf128mul snd_timer ablk_helper led_class snd hwmon ac rfkill psmouse cryp=
td soundcore mei_me mei serio_raw e1000e wmi intel_ips i2c_i801 shpchp ther=
mal lpc_ich ptp pps_core tpm_tis intel_agp tpm battery evdev mac_hid sch_fq=
_codel cpufreq_powersave acpi_cpufreq processor vboxnetflt(O) vboxdrv(O) tp=
_smapi(O) thinkpad_ec(O) ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid =
hid atkbd libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd
[ 1560.060615]  usbcore usb_common i8042 serio i915 button intel_gtt i2c_al=
go_bit video drm_kms_helper drm agpgart i2c_core
[ 1560.060627] CPU: 2 PID: 149 Comm: kworker/2:2 Tainted: G        W  O   3=
.18.2-2-ARCH #1
[ 1560.060630] Hardware name: LENOVO 3680BR4/3680BR4, BIOS 6QET46WW (1.16 )=
 06/07/2010
[ 1560.060640] Workqueue: events ieee80211_restart_work [mac80211]
[ 1560.060642]  00000000 24cb9ba5 00000000 f4bf1d54 c1474f33 f4bf1d98 f4bf1=
d88 c10527f2
[ 1560.060648]  f9208e60 f4bf1db8 00000095 f920b267 0000000c f91b8e82 00000=
00c f91b8e82
[ 1560.060655]  f2c48cd8 00000000 f40dbcf8 f4bf1da4 c105284e 00000009 f4bf1=
d98 f9208e60
[ 1560.060661] Call Trace:
[ 1560.060667]  [<c1474f33>] dump_stack+0x48/0x69
[ 1560.060672]  [<c10527f2>] warn_slowpath_common+0x82/0xa0
[ 1560.060687]  [<f91b8e82>] ? ieee80211_do_stop+0x872/0x890 [mac80211]
[ 1560.060701]  [<f91b8e82>] ? ieee80211_do_stop+0x872/0x890 [mac80211]
[ 1560.060705]  [<c105284e>] warn_slowpath_fmt+0x3e/0x60
[ 1560.060720]  [<f91b8e82>] ieee80211_do_stop+0x872/0x890 [mac80211]
[ 1560.060727]  [<c13b8699>] ? dev_deactivate_many+0x1a9/0x1f0
[ 1560.060741]  [<f91b8eb7>] ieee80211_stop+0x17/0x20 [mac80211]
[ 1560.060748]  [<c1395059>] __dev_close_many+0x79/0xe0
[ 1560.060752]  [<c139512d>] dev_close_many+0x6d/0xf0
[ 1560.060757]  [<c1398c90>] dev_close.part.77+0x30/0x50
[ 1560.060761]  [<c1398cc6>] dev_close+0x16/0x20
[ 1560.060772]  [<f85627b5>] cfg80211_shutdown_all_interfaces+0x45/0xb0 [cf=
g80211]
[ 1560.060776]  [<c105284e>] ? warn_slowpath_fmt+0x3e/0x60
[ 1560.060793]  [<f91d14ec>] ieee80211_reconfig+0x2cc/0x16a0 [mac80211]
[ 1560.060798]  [<c1477bd4>] ? __mutex_lock_slowpath+0x34/0x120
[ 1560.060809]  [<f91a42ed>] ieee80211_restart_work+0x3d/0x80 [mac80211]
[ 1560.060813]  [<c1067580>] ? pwq_dec_nr_in_flight+0x40/0x90
[ 1560.060817]  [<c1067a63>] process_one_work+0x113/0x380
[ 1560.060821]  [<c14767d6>] ? preempt_schedule+0x36/0x50
[ 1560.060825]  [<c1067f59>] worker_thread+0x39/0x440
[ 1560.060829]  [<c1067f20>] ? init_pwq.part.30+0x10/0x10
[ 1560.060832]  [<c106c173>] kthread+0xb3/0xd0
[ 1560.060837]  [<c1479bc1>] ret_from_kernel_thread+0x21/0x30
[ 1560.060840]  [<c106c0c0>] ? kthread_create_on_node+0x130/0x130
[ 1560.060843] ---[ end trace a5b5252fd3fa22c7 ]---
[ 1560.061547] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ 1560.062625] cfg80211: Calling CRDA to update world regulatory domain
=

--=-hH6fUeRMi8urh0F4ezJc--
