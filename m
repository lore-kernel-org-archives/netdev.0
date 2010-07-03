From: Nico Schottelius <nico-linux-20100702@schottelius.org>
Subject: Re: e1000e: receives no packets after resume
 (2.6.35-rc3-00262-g984bc96)
Date: Sat, 3 Jul 2010 10:17:32 +0200
Message-ID: <20100703081732.GA24281@schottelius.org>
References: <20100702072826.GB16856@schottelius.org>
 <AANLkTikO8yXXBC9Wt4LKZeu1JD5TKMOW5reB3jpk8Ahp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Bu8it7iiRSEf40bY"
Cc: Nico Schottelius <nico-linux-20100702@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikO8yXXBC9Wt4LKZeu1JD5TKMOW5reB3jpk8Ahp@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Bu8it7iiRSEf40bY
Content-Type: multipart/mixed; boundary="JP+T4n/bALQSJXh8"
Content-Disposition: inline


--JP+T4n/bALQSJXh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey Jeff,

Jeff Kirsher [Fri, Jul 02, 2010 at 02:47:26PM -0700]:
> On Fri, Jul 2, 2010 at 00:28, Nico Schottelius
> <nico-linux-20100702@schottelius.org> wrote:
> [...]=20
> Adding the Networking Kernel mailing list (netdev) and Intel Linux LAN
> Driver mailing list (e1000-patches)...
>=20
> Would it be possible to get more information about the system/setup?
>=20
> For example, can you provide the following information:
>      - full lspci output (lspci -vvv)
>      - ethtool -i ethX
>      - dmesg  - after loading the driver and configuring the interfaces
>      - kernel config

Attached!

Cheers,

Nico


---------------------------------------------------------------------------=
-----

[    5.288439] PM: Adding info for No Bus:tpacpi::dock_status2
[    5.288446] Registered led device: tpacpi::dock_status2
[    5.288457] PM: Adding info for No Bus:tpacpi::unknown_led2
[    5.288464] Registered led device: tpacpi::unknown_led2
[    5.288475] PM: Adding info for No Bus:tpacpi::unknown_led3
[    5.288483] Registered led device: tpacpi::unknown_led3
[    5.288493] PM: Adding info for No Bus:tpacpi::thinkvantage
[    5.288500] Registered led device: tpacpi::thinkvantage
[    5.288502] thinkpad_acpi: warning: userspace override of important firm=
ware LEDs is enabled
[    5.290590] thinkpad_acpi: Standard ACPI backlight interface available, =
not loading native one.
[    5.290624] PM: Adding info for No Bus:card29
[    5.290706] PM: Adding info for No Bus:controlC29
[    5.290856] thinkpad_acpi: Console audio control enabled, mode: monitor =
(read only)
[    5.292521] agpgart-intel 0000:00:00.0: Intel HD Graphics Chipset
[    5.293841] agpgart-intel 0000:00:00.0: detected 32764K stolen memory
[    5.295322] PM: Adding info for No Bus:input6
[    5.295360] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_=
acpi/input/input6
[    5.295461] PM: Adding info for No Bus:event6
[    5.360382] PM: Adding info for No Bus:agpgart
[    5.360403] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    5.397485] PM: Adding info for usb:1-1
[    5.397670] PM: Adding info for usb:1-1:1.0
[    5.397699] hub 1-1:1.0: USB hub found
[    5.397761] hub 1-1:1.0: 6 ports detected
[    5.398775] PM: Adding info for No Bus:ep_81
[    5.398790] PM: Adding info for No Bus:ep_00
[    5.436091] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, in=
-tree:d
[    5.436094] iwlagn: Copyright(c) 2003-2010 Intel Corporation
[    5.436195] iwlagn 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ=
 16
[    5.436225] iwlagn 0000:02:00.0: setting latency timer to 64
[    5.436332] iwlagn 0000:02:00.0: Detected Intel(R) Centrino(R) Ultimate-=
N 6300 AGN, REV=3D0x74
[    5.452962] iwlagn 0000:02:00.0: Tunable channels: 13 802.11bg, 24 802.1=
1a channels
[    5.453108] iwlagn 0000:02:00.0: irq 46 for MSI/MSI-X
[    5.453370] PM: Adding info for No Bus:0000:02:00.0
[    5.500939] usb 2-1: new high speed USB device using ehci_hcd and addres=
s 2
[    5.615125] PM: Adding info for usb:2-1
[    5.615283] PM: Adding info for usb:2-1:1.0
[    5.615300] hub 2-1:1.0: USB hub found
[    5.615391] hub 2-1:1.0: 8 ports detected
[    5.616653] PM: Adding info for No Bus:ep_81
[    5.616667] PM: Adding info for No Bus:ep_00
[    5.617965] PM: Removing info for No Bus:0000:02:00.0
[    5.617992] iwlagn 0000:02:00.0: loaded firmware version 9.193.4.1 build=
 19710
[    5.618333] PM: Adding info for No Bus:phy0
[    5.618356] PM: Adding info for No Bus:rfkill1
[    5.678677] usb 1-1.3: new full speed USB device using ehci_hcd and addr=
ess 3
[    5.765007] PM: Adding info for usb:1-1.3
[    5.765159] PM: Adding info for usb:1-1.3:1.0
[    5.765188] PM: Adding info for No Bus:ep_81
[    5.765196] PM: Adding info for No Bus:ep_02
[    5.765204] PM: Adding info for No Bus:ep_83
[    5.765220] PM: Adding info for No Bus:ep_00
[    5.838256] usb 1-1.4: new full speed USB device using ehci_hcd and addr=
ess 4
[    5.927441] PM: Adding info for usb:1-1.4
[    5.927619] PM: Adding info for usb:1-1.4:1.0
[    5.927649] PM: Adding info for No Bus:ep_81
[    5.927660] PM: Adding info for No Bus:ep_82
[    5.927671] PM: Adding info for No Bus:ep_02
[    5.927681] PM: Adding info for usb:1-1.4:1.1
[    5.927700] PM: Adding info for No Bus:ep_83
[    5.927710] PM: Adding info for No Bus:ep_03
[    5.927721] PM: Adding info for usb:1-1.4:1.2
[    5.927737] PM: Adding info for No Bus:ep_84
[    5.927747] PM: Adding info for No Bus:ep_04
[    5.927755] PM: Adding info for usb:1-1.4:1.3
[    5.927772] PM: Adding info for No Bus:ep_00
[    5.948522] phy0: Selected rate control algorithm 'iwl-agn-rs'
[    5.948584] PM: Adding info for No Bus:wlan0
[    5.976526] Bluetooth: Core ver 2.15
[    5.976548] NET: Registered protocol family 31
[    5.976550] Bluetooth: HCI device and connection manager initialized
[    5.976553] Bluetooth: HCI socket layer initialized
[    6.001059] usb 1-1.5: new high speed USB device using ehci_hcd and addr=
ess 5
[    6.027005] Bluetooth: Generic Bluetooth USB driver ver 0.6
[    6.027076] PM: Adding info for No Bus:hci0
[    6.027105] PM: Adding info for No Bus:rfkill2
[    6.027162] usbcore: registered new interface driver btusb
[    6.089247] PM: Adding info for usb:1-1.5
[    6.089368] PM: Adding info for usb:1-1.5:1.0
[    6.089399] hub 1-1.5:1.0: USB hub found
[    6.089502] hub 1-1.5:1.0: 4 ports detected
[    6.089593] PM: Adding info for No Bus:ep_81
[    6.090362] PM: Adding info for No Bus:ep_00
[    6.163850] usb 1-1.6: new high speed USB device using ehci_hcd and addr=
ess 6
[    6.254550] PM: Adding info for usb:1-1.6
[    6.254695] PM: Adding info for usb:1-1.6:1.0
[    6.255213] PM: Adding info for No Bus:ep_81
[    6.255249] PM: Adding info for usb:1-1.6:1.1
[    6.255295] PM: Adding info for No Bus:ep_00
[    6.325189] PM: Adding info for No Bus:device-mapper
[    6.325201] device-mapper: ioctl: 4.17.0-ioctl (2010-03-05) initialised:=
 dm-devel@redhat.com
[    6.339459] Linux video capture interface: v2.00
[    6.343336] uvcvideo: Found UVC 1.00 device Integrated Camera (17ef:4816)
[    6.344476] PM: Adding info for No Bus:video0
[    6.344518] PM: Adding info for No Bus:input7
[    6.344536] input: Integrated Camera as /devices/pci0000:00/0000:00:1a.0=
/usb1/1-1/1-1.6/1-1.6:1.0/input/input7
[    6.344560] PM: Adding info for No Bus:event7
[    6.344585] usbcore: registered new interface driver uvcvideo
[    6.344586] USB Video Class driver (v0.1.0)
[    8.262514] IBM TrackPoint firmware: 0x0e, buttons: 3/3
[    8.535556] PM: Adding info for No Bus:input8
[    8.535595] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/seri=
o1/serio2/input/input8
[    8.535687] PM: Adding info for No Bus:mouse1
[    8.535781] PM: Adding info for No Bus:event8
[   12.565616] usb 1-1.5.2: new high speed USB device using ehci_hcd and ad=
dress 7
[   12.651792] PM: Adding info for usb:1-1.5.2
[   12.651913] PM: Adding info for usb:1-1.5.2:1.0
[   12.651946] PM: Adding info for No Bus:ep_81
[   12.651958] PM: Adding info for No Bus:ep_02
[   12.651974] PM: Adding info for No Bus:ep_00
[   12.715410] usbcore: registered new interface driver libusual
[   12.724669] Initializing USB Mass Storage driver...
[   12.724945] scsi6 : usb-storage 1-1.5.2:1.0
[   12.724965] PM: Adding info for scsi:host6
[   12.725038] PM: Adding info for No Bus:host6
[   12.725157] usbcore: registered new interface driver usb-storage
[   12.725162] USB Mass Storage support registered.
[   13.724079] scsi 6:0:0:0: Direct-Access     WD       5000BEV External 1.=
75 PQ: 0 ANSI: 4
[   13.724094] PM: Adding info for scsi:target6:0:0
[   13.724128] PM: Adding info for scsi:6:0:0:0
[   13.724166] PM: Adding info for No Bus:6:0:0:0
[   13.724194] PM: Adding info for No Bus:6:0:0:0
[   13.724307] PM: Adding info for No Bus:sg2
[   13.724335] sd 6:0:0:0: Attached scsi generic sg2 type 0
[   13.724369] PM: Adding info for No Bus:6:0:0:0
[   13.725007] sd 6:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB=
/465 GiB)
[   13.725562] sd 6:0:0:0: [sdb] Write Protect is off
[   13.725569] sd 6:0:0:0: [sdb] Mode Sense: 23 00 00 00
[   13.725574] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[   13.725644] PM: Adding info for No Bus:sdb
[   13.726795] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[   13.726803]  sdb: sdb1
[   13.733076] PM: Adding info for No Bus:sdb1
[   13.733168] PM: Adding info for No Bus:8:16
[   13.734284] sd 6:0:0:0: [sdb] Assuming drive cache: write through
[   13.734288] sd 6:0:0:0: [sdb] Attached SCSI disk
[   19.580107] PM: Adding info for No Bus:dm-0
[   19.580155] PM: Adding info for No Bus:254:0
[   19.716444] padlock: VIA PadLock not detected.
[   19.757634] PM: Removing info for No Bus:254:0
[   19.757702] PM: Removing info for No Bus:dm-0
[   20.026561] PM: Adding info for No Bus:dm-0
[   20.026603] PM: Adding info for No Bus:254:0
[   20.232295] PM: Adding info for No Bus:dm-1
[   20.232339] PM: Adding info for No Bus:254:1
[   20.235306] alg: No test for __cbc-aes-aesni (cryptd(__driver-cbc-aes-ae=
sni))
[   20.298248] padlock: VIA PadLock Hash Engine not detected.
[   21.305564] Adding 4000148k swap on /dev/mapper/swap.  Priority:-1 exten=
ts:1 across:4000148k=20
[   23.067258] PM: Adding info for No Bus:vcs10
[   23.067284] PM: Adding info for No Bus:vcsa10
[   23.067913] PM: Adding info for No Bus:vcs11
[   23.067933] PM: Adding info for No Bus:vcsa11
[   23.068596] PM: Adding info for No Bus:vcs12
[   23.068639] PM: Adding info for No Bus:vcsa12
[   23.069321] PM: Adding info for No Bus:vcs13
[   23.069342] PM: Adding info for No Bus:vcsa13
[   23.069929] PM: Adding info for No Bus:vcs14
[   23.069951] PM: Adding info for No Bus:vcsa14
[   23.070661] PM: Adding info for No Bus:vcs15
[   23.070705] PM: Adding info for No Bus:vcsa15
[   23.071375] PM: Adding info for No Bus:vcs16
[   23.071396] PM: Adding info for No Bus:vcsa16
[   23.072381] PM: Adding info for No Bus:vcs17
[   23.072424] PM: Adding info for No Bus:vcsa17
[   23.073096] PM: Adding info for No Bus:vcs18
[   23.073117] PM: Adding info for No Bus:vcsa18
[   23.073964] PM: Adding info for No Bus:vcs19
[   23.074014] PM: Adding info for No Bus:vcsa19
[   23.074872] PM: Adding info for No Bus:vcs2
[   23.074915] PM: Adding info for No Bus:vcsa2
[   23.075695] PM: Adding info for No Bus:vcs20
[   23.075738] PM: Adding info for No Bus:vcsa20
[   23.076437] PM: Adding info for No Bus:vcs21
[   23.076462] PM: Adding info for No Bus:vcsa21
[   23.077041] PM: Adding info for No Bus:vcs22
[   23.077063] PM: Adding info for No Bus:vcsa22
[   23.077739] PM: Adding info for No Bus:vcs23
[   23.077783] PM: Adding info for No Bus:vcsa23
[   23.078499] PM: Adding info for No Bus:vcs24
[   23.078524] PM: Adding info for No Bus:vcsa24
[   23.079216] PM: Adding info for No Bus:vcs25
[   23.079238] PM: Adding info for No Bus:vcsa25
[   23.079821] PM: Adding info for No Bus:vcs26
[   23.079843] PM: Adding info for No Bus:vcsa26
[   23.080424] PM: Adding info for No Bus:vcs27
[   23.080446] PM: Adding info for No Bus:vcsa27
[   23.081044] PM: Adding info for No Bus:vcs28
[   23.081066] PM: Adding info for No Bus:vcsa28
[   23.081775] PM: Adding info for No Bus:vcs29
[   23.081823] PM: Adding info for No Bus:vcsa29
[   23.082534] PM: Adding info for No Bus:vcs3
[   23.082581] PM: Adding info for No Bus:vcsa3
[   23.083291] PM: Adding info for No Bus:vcs30
[   23.083313] PM: Adding info for No Bus:vcsa30
[   23.084235] PM: Adding info for No Bus:vcs31
[   23.084276] PM: Adding info for No Bus:vcsa31
[   23.084945] PM: Adding info for No Bus:vcs32
[   23.084968] PM: Adding info for No Bus:vcsa32
[   23.085660] PM: Adding info for No Bus:vcs33
[   23.085686] PM: Adding info for No Bus:vcsa33
[   23.086272] PM: Adding info for No Bus:vcs34
[   23.086295] PM: Adding info for No Bus:vcsa34
[   23.086892] PM: Adding info for No Bus:vcs35
[   23.086920] PM: Adding info for No Bus:vcsa35
[   23.087489] PM: Adding info for No Bus:vcs36
[   23.087520] PM: Adding info for No Bus:vcsa36
[   23.088104] PM: Adding info for No Bus:vcs37
[   23.088127] PM: Adding info for No Bus:vcsa37
[   23.088709] PM: Adding info for No Bus:vcs38
[   23.088731] PM: Adding info for No Bus:vcsa38
[   23.089303] PM: Adding info for No Bus:vcs39
[   23.089328] PM: Adding info for No Bus:vcsa39
[   23.089914] PM: Adding info for No Bus:vcs4
[   23.089936] PM: Adding info for No Bus:vcsa4
[   23.090524] PM: Adding info for No Bus:vcs40
[   23.090548] PM: Adding info for No Bus:vcsa40
[   23.091123] PM: Adding info for No Bus:vcs41
[   23.091146] PM: Adding info for No Bus:vcsa41
[   23.091726] PM: Adding info for No Bus:vcs42
[   23.091749] PM: Adding info for No Bus:vcsa42
[   23.092320] PM: Adding info for No Bus:vcs43
[   23.092345] PM: Adding info for No Bus:vcsa43
[   23.092944] PM: Adding info for No Bus:vcs44
[   23.092967] PM: Adding info for No Bus:vcsa44
[   23.093557] PM: Adding info for No Bus:vcs45
[   23.093581] PM: Adding info for No Bus:vcsa45
[   23.094168] PM: Adding info for No Bus:vcs46
[   23.094191] PM: Adding info for No Bus:vcsa46
[   23.094778] PM: Adding info for No Bus:vcs47
[   23.094802] PM: Adding info for No Bus:vcsa47
[   23.095372] PM: Adding info for No Bus:vcs48
[   23.095399] PM: Adding info for No Bus:vcsa48
[   23.095979] PM: Adding info for No Bus:vcs49
[   23.096003] PM: Adding info for No Bus:vcsa49
[   23.096625] PM: Adding info for No Bus:vcs5
[   23.096663] PM: Adding info for No Bus:vcsa5
[   23.097311] PM: Adding info for No Bus:vcs50
[   23.097340] PM: Adding info for No Bus:vcsa50
[   23.097917] PM: Adding info for No Bus:vcs51
[   23.097942] PM: Adding info for No Bus:vcsa51
[   23.098536] PM: Adding info for No Bus:vcs52
[   23.098575] PM: Adding info for No Bus:vcsa52
[   23.099232] PM: Adding info for No Bus:vcs53
[   23.099258] PM: Adding info for No Bus:vcsa53
[   23.099841] PM: Adding info for No Bus:vcs54
[   23.099866] PM: Adding info for No Bus:vcsa54
[   23.100478] PM: Adding info for No Bus:vcs55
[   23.100518] PM: Adding info for No Bus:vcsa55
[   23.101175] PM: Adding info for No Bus:vcs56
[   23.101199] PM: Adding info for No Bus:vcsa56
[   23.101778] PM: Adding info for No Bus:vcs57
[   23.101803] PM: Adding info for No Bus:vcsa57
[   23.102395] PM: Adding info for No Bus:vcs58
[   23.102422] PM: Adding info for No Bus:vcsa58
[   23.103003] PM: Adding info for No Bus:vcs59
[   23.103029] PM: Adding info for No Bus:vcsa59
[   23.103708] PM: Adding info for No Bus:vcs6
[   23.103749] PM: Adding info for No Bus:vcsa6
[   23.104698] PM: Adding info for No Bus:vcs60
[   23.104742] PM: Adding info for No Bus:vcsa60
[   23.105717] PM: Adding info for No Bus:vcs61
[   23.105761] PM: Adding info for No Bus:vcsa61
[   23.106742] PM: Adding info for No Bus:vcs62
[   23.106787] PM: Adding info for No Bus:vcsa62
[   23.107792] PM: Adding info for No Bus:vcs63
[   23.107835] PM: Adding info for No Bus:vcsa63
[   23.108873] PM: Adding info for No Bus:vcs7
[   23.108917] PM: Adding info for No Bus:vcsa7
[   23.109886] PM: Adding info for No Bus:vcs8
[   23.109936] PM: Adding info for No Bus:vcsa8
[   23.110911] PM: Adding info for No Bus:vcs9
[   23.110956] PM: Adding info for No Bus:vcsa9
[   27.819859] NET: Registered protocol family 10
[   27.820233] lo: Disabled Privacy Extensions
[   42.533689] [drm] Initialized drm 1.1.0 20060810
[   42.556343] i915 0000:00:02.0: power state changed by ACPI to D0
[   42.556444] i915 0000:00:02.0: power state changed by ACPI to D0
[   42.556456] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   42.556467] i915 0000:00:02.0: setting latency timer to 64
[   42.558017] PM: Adding info for No Bus:controlD64
[   42.558097] PM: Adding info for No Bus:card0
[   42.617838] i915 0000:00:02.0: irq 47 for MSI/MSI-X
[   42.617853] [drm] set up 31M of stolen space
[   42.618149] PM: Adding info for i2c:i2c-1
[   42.618242] PM: Adding info for No Bus:card0-VGA-1
[   42.618275] PM: Adding info for i2c:i2c-2
[   42.729204] PM: Adding info for No Bus:card0-LVDS-1
[   42.729232] PM: Adding info for i2c:i2c-3
[   42.729311] PM: Adding info for No Bus:card0-HDMI Type A-1
[   42.729339] PM: Adding info for No Bus:card0-DisplayPort-1
[   42.734458] PM: Adding info for i2c:i2c-4
[   43.386680] PM: Adding info for No Bus:fb0
[   43.386708] fb0: inteldrmfb frame buffer device
[   43.386709] drm: registered panic notifier
[   43.386712] Slow work thread pool: Starting up
[   43.386989] Slow work thread pool: Ready
[   43.393013] PM: Adding info for No Bus:acpi_video0
[   43.393147] PM: Adding info for No Bus:cooling_device4
[   43.393159] acpi device:01: registered as cooling_device4
[   43.393175] PM: Adding info for No Bus:acpi_video0
[   43.393419] PM: Adding info for No Bus:input9
[   43.393439] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08=
:00/LNXVIDEO:00/input/input9
[   43.393480] PM: Adding info for No Bus:event9
[   43.393518] ACPI: Video Device [VID] (multi-head: yes  rom: no  post: no)
[   43.393605] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on mi=
nor 0
[   43.473547] PM: Adding info for No Bus:fbcon
[   43.473599] PM: Adding info for No Bus:vtcon1
[   43.475006] Console: switching to colour frame buffer device 160x50
[  769.483930] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[  769.534280] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[  769.535045] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  773.902855] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Cont=
rol: RX
[  773.906454] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  784.684331] eth0: no IPv6 routers present
[30122.917094] ata2.00: disabled
[30122.917119] ata2.00: detaching (SCSI 1:0:0:0)
[30122.917130] PM: Removing info for No Bus:1:0:0:0
[30122.917207] PM: Removing info for acpi:LNXIOBAY:00
[30122.917235] PM: Removing info for No Bus:1:0:0:0
[30122.917255] PM: Removing info for No Bus:sg1
[30122.917288] PM: Removing info for acpi:device:30
[30122.917334] PM: Removing info for scsi:1:0:0:0
[30122.917354] PM: Removing info for acpi:IBM0079:00
[30122.917392] ACPI: \_SB_.GDCK - undocking
[30122.919801] PM: Removing info for No Bus:11:0
[30122.919850] PM: Removing info for No Bus:sr0
[30122.919947] ata2: exception Emask 0x50 SAct 0x0 SErr 0x4090800 action 0x=
e frozen
[30122.919950] ata2: irq_stat 0x004000c0, connection status changed
[30122.919954] ata2: SError: { HostInt PHYRdyChg 10B8B DevExch }
[30122.919964] ata2: hard resetting link
[30123.174695] usb 1-1.5: USB disconnect, address 5
[30123.174700] usb 1-1.5.2: USB disconnect, address 7
[30123.174711] PM: Removing info for No Bus:ep_81
[30123.174739] PM: Removing info for No Bus:ep_02
[30123.174750] PM: Removing info for usb:1-1.5.2:1.0
[30123.174775] PM: Removing info for No Bus:6:0:0:0
[30123.174867] PM: Removing info for No Bus:6:0:0:0
[30123.174882] PM: Removing info for No Bus:sg2
[30123.174956] PM: Removing info for scsi:6:0:0:0
[30123.174978] PM: Removing info for No Bus:6:0:0:0
[30123.175018] PM: Removing info for No Bus:sdb1
[30123.179950] PM: Removing info for No Bus:8:16
[30123.180018] PM: Removing info for No Bus:sdb
[30123.180084] PM: Removing info for scsi:target6:0:0
[30123.180100] PM: Removing info for No Bus:host6
[30123.180119] PM: Removing info for scsi:host6
[30123.180177] PM: Removing info for No Bus:ep_00
[30123.180191] PM: Removing info for usb:1-1.5.2
[30123.180362] PM: Removing info for No Bus:ep_81
[30123.180374] PM: Removing info for usb:1-1.5:1.0
[30123.180403] PM: Removing info for No Bus:ep_00
[30123.180412] PM: Removing info for usb:1-1.5
[30123.641068] ata2: SATA link down (SStatus 0 SControl 300)
[30123.641085] ata2: EH complete
[30123.641210] PM: Removing info for scsi:target1:0:0
[30125.798669] e1000e: eth0 NIC Link is Down
[30126.111475] thinkpad_acpi: EC reports that Thermal Table has changed
[30126.114750] ACPI: \_SB_.GDCK - undocking
[30549.447991] usb 1-1.4: USB disconnect, address 4
[30549.448004] PM: Removing info for No Bus:ep_81
[30549.448025] PM: Removing info for No Bus:ep_82
[30549.448036] PM: Removing info for No Bus:ep_02
[30549.448056] PM: Removing info for usb:1-1.4:1.0
[30549.448084] PM: Removing info for No Bus:rfkill2
[30549.448137] PM: Removing info for No Bus:hci0
[30549.448233] PM: Removing info for No Bus:ep_83
[30549.448250] PM: Removing info for No Bus:ep_03
[30549.448265] PM: Removing info for usb:1-1.4:1.1
[30549.448303] PM: Removing info for No Bus:ep_84
[30549.448318] PM: Removing info for No Bus:ep_04
[30549.448333] PM: Removing info for usb:1-1.4:1.2
[30549.448372] PM: Removing info for usb:1-1.4:1.3
[30549.448409] PM: Removing info for No Bus:ep_00
[30549.448430] PM: Removing info for usb:1-1.4
[30550.348498] PM: Syncing filesystems ... done.
[30550.487984] PM: Preparing system for mem sleep
[30551.336942] Freezing user space processes ... (elapsed 0.01 seconds) don=
e.
[30551.348139] Freezing remaining freezable tasks ... (elapsed 0.01 seconds=
) done.
[30551.359114] PM: Entering mem sleep
[30551.359231] Suspending console(s) (use no_console_suspend to debug)
[30551.359258] platform dock.0: preparing suspend
[30551.359260] platform dock.1: preparing suspend
[30551.359262] platform dock.2: preparing suspend
[30551.359265] pci 0000:ff:00.0: preparing suspend
[30551.359267] pci 0000:ff:00.1: preparing suspend
[30551.359269] pci 0000:ff:02.0: preparing suspend
[30551.359270] pci 0000:ff:02.1: preparing suspend
[30551.359272] pci 0000:ff:02.2: preparing suspend
[30551.359274] pci 0000:ff:02.3: preparing suspend
[30551.359277] agpgart-intel 0000:00:00.0: preparing suspend
[30551.359279] i915 0000:00:02.0: preparing suspend
[30551.359281] pci 0000:00:16.0: preparing suspend
[30551.359283] serial 0000:00:16.3: preparing suspend
[30551.359285] e1000e 0000:00:19.0: preparing suspend, may wakeup
[30551.359288] ehci_hcd 0000:00:1a.0: preparing suspend
[30551.359290] HDA Intel 0000:00:1b.0: preparing suspend
[30551.359292] pcieport 0000:00:1c.0: preparing suspend
[30551.359294] pcieport 0000:00:1c.3: preparing suspend
[30551.359295] pcieport 0000:00:1c.4: preparing suspend
[30551.359297] ehci_hcd 0000:00:1d.0: preparing suspend
[30551.359299] pci 0000:00:1e.0: preparing suspend
[30551.359301] pci 0000:00:1f.0: preparing suspend
[30551.359302] ahci 0000:00:1f.2: preparing suspend
[30551.359304] i801_smbus 0000:00:1f.3: preparing suspend
[30551.359306] pci 0000:00:1f.6: preparing suspend
[30551.359309] iwlagn 0000:02:00.0: preparing suspend
[30551.359316] pcspkr pcspkr: preparing suspend
[30551.359318] platform microcode: preparing suspend
[30551.359407] i8042 i8042: preparing suspend
[30551.359416] platform regulatory.0: preparing suspend
[30551.359418] serial8250 serial8250: preparing suspend
[30551.359422] usb usb1: preparing type suspend, may wakeup
[30551.359425] usb usb2: preparing type suspend, may wakeup
[30551.359432] thinkpad_acpi thinkpad_acpi: preparing suspend
[30551.359434] thinkpad_hwmon thinkpad_hwmon: preparing suspend
[30551.359440] usb 1-1: preparing type suspend
[30551.359443] usb 2-1: preparing type suspend
[30551.359446] usb 1-1.3: preparing type suspend
[30551.359449] usb 1-1.6: preparing type suspend
[30551.359481] input input9: type suspend
[30551.359485] backlight acpi_video0: legacy class suspend
[30551.359488] i2c i2c-4: suspend
[30551.359490] drm card0-DisplayPort-1: legacy class suspend
[30551.359493] drm card0-HDMI Type A-1: legacy class suspend
[30551.359494] i2c i2c-3: suspend
[30551.359496] drm card0-LVDS-1: legacy class suspend
[30551.359498] i2c i2c-2: suspend
[30551.359499] drm card0-VGA-1: legacy class suspend
[30551.359501] i2c i2c-1: suspend
[30551.359503] drm card0: legacy class suspend
[30551.359505] drm controlD64: legacy class suspend
[30551.359550] input input8: type suspend
[30551.359553] input input7: type suspend
[30551.359562] rfkill rfkill1: legacy class suspend
[30551.359565] ieee80211 phy0: legacy class suspend
[30551.359653] usb 1-1.6: type suspend
[30551.359664] usb 1-1.3: type suspend
[30551.371221] input input6: type suspend
[30551.371225] usb 2-1: type suspend
[30551.371230] leds tpacpi::thinkvantage: legacy class suspend
[30551.371234] leds tpacpi::unknown_led3: legacy class suspend
[30551.371238] leds tpacpi::unknown_led2: legacy class suspend
[30551.371242] leds tpacpi::dock_status2: legacy class suspend
[30551.371246] leds tpacpi::dock_status1: legacy class suspend
[30551.371250] leds tpacpi::standby: legacy class suspend
[30551.371254] leds tpacpi::unknown_led: legacy class suspend
[30551.371258] leds tpacpi::dock_batt: legacy class suspend
[30551.371262] leds tpacpi::bay_active: legacy class suspend
[30551.371266] leds tpacpi::dock_active: legacy class suspend
[30551.371271] usb 1-1: type suspend
[30551.371275] leds tpacpi:green:batt: legacy class suspend
[30551.371279] leds tpacpi:orange:batt: legacy class suspend
[30551.371283] leds tpacpi::power: legacy class suspend
[30551.371287] leds tpacpi::thinklight: legacy class suspend
[30551.371291] rfkill rfkill0: legacy class suspend
[30551.371296] thinkpad_hwmon thinkpad_hwmon: suspend
[30551.371302] thinkpad_acpi thinkpad_acpi: suspend
[30551.371337] i2c i2c-0: suspend
[30551.371339] usb usb2: type suspend, may wakeup
[30551.371343] serial8250 serial8250: suspend
[30551.371346] platform regulatory.0: suspend
[30551.371348] usb usb1: type suspend, may wakeup
[30551.371351] input input5: type suspend
[30551.371354] psmouse serio2: suspend
[30551.535700] input input4: type suspend
[30551.535723] input input3: type suspend
[30551.535727] sd 0:0:0:0: legacy suspend
[30551.535731] psmouse serio1: suspend
[30551.535736] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[30551.573126] sd 0:0:0:0: [sda] Stopping disk
[30551.587059] atkbd serio0: suspend
[30551.587598] i8042 i8042: suspend
[30551.588203] scsi host5: legacy suspend
[30551.588210] scsi host4: legacy suspend
[30551.588213] scsi host3: legacy suspend
[30551.588216] scsi host2: legacy suspend
[30551.588220] scsi host1: legacy suspend
[30551.588370] input input2: type suspend
[30551.588372] input input1: type suspend
[30551.588374] input input0: type suspend
[30551.588379] platform microcode: suspend
[30551.588381] pcspkr pcspkr: suspend
[30551.588391] system 00:0c: legacy suspend
[30551.588393] ACPI handle has no context!
[30551.588398] tpm_tis 00:0b: legacy suspend
[30551.779359] i8042 aux 00:0a: legacy suspend
[30551.779371] i8042 kbd 00:09: legacy suspend
[30551.779382] rtc_cmos 00:08: legacy suspend, may wakeup
[30551.779396] pnp 00:07: legacy suspend
[30551.779399] pnp 00:06: legacy suspend
[30551.779402] pnp 00:05: legacy suspend
[30551.779404] pnp 00:04: legacy suspend
[30551.779407] system 00:03: legacy suspend
[30551.779419] pnp 00:02: legacy suspend
[30551.779421] pnp 00:01: legacy suspend
[30551.779422] system 00:00: legacy suspend
[30551.779486] pci 0000:00:1f.6: suspend
[30551.779488] i801_smbus 0000:00:1f.3: suspend
[30551.779491] iwlagn 0000:02:00.0: suspend
[30551.779604] pci 0000:00:1f.0: suspend
[30551.779606] pci 0000:00:1e.0: suspend
[30551.779608] ehci_hcd 0000:00:1d.0: suspend
[30551.779688] ehci_hcd 0000:00:1d.0: PCI INT D disabled
[30551.779692] pcieport 0000:00:1c.3: suspend
[30551.779696] pcieport 0000:00:1c.0: suspend
[30551.779699] HDA Intel 0000:00:1b.0: suspend
[30551.779716] ehci_hcd 0000:00:1a.0: suspend
[30551.779858] ehci_hcd 0000:00:1a.0: PCI INT D disabled
[30551.779862] e1000e 0000:00:19.0: suspend, may wakeup
[30551.779940] serial 0000:00:16.3: suspend
[30551.779975] pci 0000:00:16.0: suspend
[30551.779980] i915 0000:00:02.0: suspend
[30551.780122] platform dock.2: suspend
[30551.780145] platform dock.1: suspend
[30551.780147] platform dock.0: suspend
[30551.780170] button LNXPWRBN:00: legacy suspend
[30551.780173] thermal LNXTHERM:01: legacy suspend
[30551.780196] acpi LNXTHERM:00: legacy suspend
[30551.780219] wmi PNP0C14:00: legacy suspend
[30551.780221] acpi PNP0C02:01: legacy suspend
[30551.780243] acpi device:32: legacy suspend
[30551.780246] acpi device:31: legacy suspend
[30551.780268] acpi device:2f: legacy suspend
[30551.780270] acpi device:2e: legacy suspend
[30551.780272] acpi device:2d: legacy suspend
[30551.780294] acpi device:2c: legacy suspend
[30551.780296] acpi device:2b: legacy suspend
[30551.780319] acpi device:2a: legacy suspend
[30551.780321] acpi device:29: legacy suspend
[30551.780343] acpi device:28: legacy suspend
[30551.780345] acpi device:27: legacy suspend
[30551.780367] acpi device:26: legacy suspend
[30551.780369] acpi device:25: legacy suspend
[30551.780372] acpi device:24: legacy suspend
[30551.780374] acpi device:23: legacy suspend
[30551.780376] agpgart-intel 0000:00:00.0: suspend
[30551.780378] acpi device:22: legacy suspend
[30551.780380] ACPI handle has no context!
[30551.780382] acpi device:21: legacy suspend
[30551.780386] acpi device:20: legacy suspend
[30551.780389] acpi device:1f: legacy suspend
[30551.780391] acpi device:1e: legacy suspend
[30551.780393] pci 0000:ff:02.3: suspend
[30551.780395] acpi device:1d: legacy suspend
[30551.780397] pci 0000:ff:02.2: suspend
[30551.780399] acpi device:1c: legacy suspend
[30551.780401] pci 0000:ff:02.1: suspend
[30551.780403] acpi device:1b: legacy suspend
[30551.780405] acpi device:1a: legacy suspend
[30551.780408] pci 0000:ff:02.0: suspend
[30551.780409] acpi device:19: legacy suspend
[30551.780411] pci 0000:ff:00.1: suspend
[30551.780413] acpi device:18: legacy suspend
[30551.780415] pci 0000:ff:00.0: suspend
[30551.780418] acpi device:17: legacy suspend
[30551.780420] acpi device:16: legacy suspend
[30551.780423] acpi device:15: legacy suspend
[30551.780425] acpi device:14: legacy suspend
[30551.780427] acpi device:13: legacy suspend
[30551.780429] acpi device:12: legacy suspend
[30551.780432] acpi device:11: legacy suspend
[30551.780434] acpi device:10: legacy suspend
[30551.780436] acpi device:0f: legacy suspend
[30551.780438] acpi device:0e: legacy suspend
[30551.780440] acpi device:0d: legacy suspend
[30551.780443] acpi device:0c: legacy suspend
[30551.780445] acpi device:0b: legacy suspend
[30551.780447] acpi LNXVIDEO:01: legacy suspend
[30551.780449] acpi device:0a: legacy suspend
[30551.780451] thinkpad_hotkey IBM0068:00: legacy suspend
[30551.780454] ac ACPI0003:00: legacy suspend
[30551.780456] battery PNP0C0A:00: legacy suspend
[30551.780458] power LNXPOWER:00: legacy suspend
[30551.780460] ec PNP0C09:00: legacy suspend
[30551.780466] acpi SMO1200:00: legacy suspend
[30551.780468] acpi LEN0018:00: legacy suspend
[30551.780470] acpi PNP0303:00: legacy suspend
[30551.780471] acpi PNP0B00:00: legacy suspend
[30551.780473] acpi PNP0C04:00: legacy suspend
[30551.780476] acpi PNP0800:00: legacy suspend
[30551.780478] acpi PNP0200:00: legacy suspend
[30551.780480] acpi PNP0103:00: legacy suspend
[30551.780482] acpi PNP0100:00: legacy suspend
[30551.780483] acpi PNP0000:00: legacy suspend
[30551.780485] acpi PNP0C02:00: legacy suspend
[30551.780488] acpi device:09: legacy suspend
[30551.780489] acpi device:08: legacy suspend
[30551.780491] acpi device:07: legacy suspend
[30551.780493] acpi device:06: legacy suspend
[30551.780494] acpi device:05: legacy suspend
[30551.780496] acpi device:04: legacy suspend
[30551.780497] acpi device:03: legacy suspend
[30551.780499] acpi device:02: legacy suspend
[30551.780500] acpi device:01: legacy suspend
[30551.780503] video LNXVIDEO:00: legacy suspend
[30551.780507] pci_root PNP0A08:00: legacy suspend
[30551.780509] acpi device:00: legacy suspend
[30551.780511] pci_root PNP0A03:00: legacy suspend
[30551.780512] button PNP0C0E:00: legacy suspend
[30551.780515] button PNP0C0D:00: legacy suspend
[30551.780516] acpi PNP0C01:00: legacy suspend
[30551.780518] pci_link PNP0C0F:07: legacy suspend
[30551.780520] pci_link PNP0C0F:06: legacy suspend
[30551.780522] pci_link PNP0C0F:05: legacy suspend
[30551.780524] pci_link PNP0C0F:04: legacy suspend
[30551.780526] pci_link PNP0C0F:03: legacy suspend
[30551.780527] pci_link PNP0C0F:02: legacy suspend
[30551.780529] pci_link PNP0C0F:01: legacy suspend
[30551.780531] pci_link PNP0C0F:00: legacy suspend
[30551.780534] acpi LNXSYBUS:00: legacy suspend
[30551.780536] processor LNXCPU:07: legacy suspend
[30551.780540] processor LNXCPU:06: legacy suspend
[30551.780542] processor LNXCPU:05: legacy suspend
[30551.780544] processor LNXCPU:04: legacy suspend
[30551.780545] processor LNXCPU:03: legacy suspend
[30551.780547] processor LNXCPU:02: legacy suspend
[30551.780549] processor LNXCPU:01: legacy suspend
[30551.780550] processor LNXCPU:00: legacy suspend
[30551.780552] acpi LNXSYSTM:00: legacy suspend
[30551.790240] pcieport 0000:00:1c.4: suspend
[30551.794279] i915 0000:00:02.0: power state changed by ACPI to D3
[30551.957621] scsi target0:0:0: legacy suspend
[30551.957627] scsi host0: legacy suspend
[30551.957633] ahci 0000:00:1f.2: suspend
[30551.960954] e1000e 0000:00:19.0: PCI INT A disabled
[30551.960962] e1000e 0000:00:19.0: PME# enabled
[30551.960972] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
[30551.980932] HDA Intel 0000:00:1b.0: PCI INT B disabled
[30552.022778] PM: suspend of devices complete after 664.563 msecs
[30552.022815] input input9: LATE type suspend
[30552.022818] i2c i2c-4: LATE suspend
[30552.022820] i2c i2c-3: LATE suspend
[30552.022822] i2c i2c-2: LATE suspend
[30552.022824] i2c i2c-1: LATE suspend
[30552.022830] input input8: LATE type suspend
[30552.022832] input input7: LATE type suspend
[30552.022835] usb 1-1.6: LATE type suspend
[30552.022837] usb 1-1.3: LATE type suspend
[30552.022840] usb 2-1: LATE type suspend
[30552.022842] usb 1-1: LATE type suspend
[30552.022844] input input6: LATE type suspend
[30552.022847] thinkpad_hwmon thinkpad_hwmon: LATE suspend
[30552.022849] thinkpad_acpi thinkpad_acpi: LATE suspend
[30552.022852] usb usb2: LATE type suspend, may wakeup
[30552.022855] usb usb1: LATE type suspend, may wakeup
[30552.022857] i2c i2c-0: LATE suspend
[30552.022859] serial8250 serial8250: LATE suspend
[30552.022862] platform regulatory.0: LATE suspend
[30552.022864] input input5: LATE type suspend
[30552.022866] psmouse serio2: LATE suspend
[30552.022869] input input4: LATE type suspend
[30552.022871] input input3: LATE type suspend
[30552.022874] psmouse serio1: LATE suspend
[30552.022876] atkbd serio0: LATE suspend
[30552.022878] i8042 i8042: LATE suspend
[30552.022900] input input2: LATE type suspend
[30552.022902] input input1: LATE type suspend
[30552.022904] input input0: LATE type suspend
[30552.022907] platform microcode: LATE suspend
[30552.022909] pcspkr pcspkr: LATE suspend
[30552.022912] iwlagn 0000:02:00.0: LATE suspend
[30552.022915] pci 0000:00:1f.6: LATE suspend
[30552.022948] i801_smbus 0000:00:1f.3: LATE suspend
[30552.022951] ahci 0000:00:1f.2: LATE suspend
[30552.022953] pci 0000:00:1f.0: LATE suspend
[30552.022983] pci 0000:00:1e.0: LATE suspend
[30552.023013] ehci_hcd 0000:00:1d.0: LATE suspend
[30552.040905] ehci_hcd 0000:00:1d.0: power state changed by ACPI to D3
[30552.040911] pcieport 0000:00:1c.4: LATE suspend
[30552.040913] pcieport 0000:00:1c.3: LATE suspend
[30552.040915] pcieport 0000:00:1c.0: LATE suspend
[30552.040917] HDA Intel 0000:00:1b.0: LATE suspend
[30552.040920] ehci_hcd 0000:00:1a.0: LATE suspend
[30552.057886] ehci_hcd 0000:00:1a.0: power state changed by ACPI to D3
[30552.057891] e1000e 0000:00:19.0: LATE suspend, may wakeup
[30552.057894] serial 0000:00:16.3: LATE suspend
[30552.057896] pci 0000:00:16.0: LATE suspend
[30552.057932] i915 0000:00:02.0: LATE suspend
[30552.057934] agpgart-intel 0000:00:00.0: LATE suspend
[30552.057946] pci 0000:ff:02.3: LATE suspend
[30552.057954] pci 0000:ff:02.2: LATE suspend
[30552.057962] pci 0000:ff:02.1: LATE suspend
[30552.057971] pci 0000:ff:02.0: LATE suspend
[30552.057979] pci 0000:ff:00.1: LATE suspend
[30552.057987] pci 0000:ff:00.0: LATE suspend
[30552.057996] platform dock.2: LATE suspend
[30552.057998] platform dock.1: LATE suspend
[30552.058000] platform dock.0: LATE suspend
[30552.058006] PM: late suspend of devices complete after 35.291 msecs
[30552.067856] ACPI: Preparing to enter system sleep state S3
[30552.105825] PM: Saving platform NVS memory
[30552.238449] Disabling non-boot CPUs ...
[30552.251673] CPU 1 is now offline
[30552.267496] CPU 2 is now offline
[30552.283449] CPU 3 is now offline
[30552.283451] SMP alternatives: switching to UP code
[30552.286990] Extended CMOS year: 2000
[18446744058.757027] Back to C!
[18446744058.757031] PM: Restoring platform NVS memory
[18446744058.894360] Extended CMOS year: 2000
[18446744058.894379] Enabling non-boot CPUs ...
[18446744058.894705] SMP alternatives: switching to SMP code
[18446744058.897584] Booting Node 0 Processor 1 APIC 0x1
[18446744058.997611] CPU1 is up
[18446744058.997744] Booting Node 0 Processor 2 APIC 0x4
[18446744059.104533] CPU2 is up
[18446744059.104664] Booting Node 0 Processor 3 APIC 0x5
[18446744059.211332] CPU3 is up
[18446744059.212791] ACPI: Waking up from system sleep state S3
[18446744059.289128] platform dock.0: EARLY resume
[18446744059.289132] platform dock.1: EARLY resume
[18446744059.289134] platform dock.2: EARLY resume
[18446744059.289137] pci 0000:ff:00.0: EARLY resume
[18446744059.289150] pci 0000:ff:00.1: EARLY resume
[18446744059.289161] pci 0000:ff:02.0: EARLY resume
[18446744059.289170] pci 0000:ff:02.1: EARLY resume
[18446744059.289180] pci 0000:ff:02.2: EARLY resume
[18446744059.289189] pci 0000:ff:02.3: EARLY resume
[18446744059.289199] agpgart-intel 0000:00:00.0: EARLY resume
[18446744059.289212] agpgart-intel 0000:00:00.0: restoring config space at =
offset 0x1 (was 0x900006, writing 0x20900006)
[18446744059.289220] i915 0000:00:02.0: EARLY resume
[18446744059.289233] i915 0000:00:02.0: restoring config space at offset 0x=
1 (was 0x900007, writing 0x900407)
[18446744059.289247] pci 0000:00:16.0: EARLY resume
[18446744059.289290] serial 0000:00:16.3: EARLY resume
[18446744059.289334] e1000e 0000:00:19.0: EARLY resume
[18446744059.289386] ehci_hcd 0000:00:1a.0: EARLY resume
[18446744059.289405] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.289426] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728000)
[18446744059.289434] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.300038] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.302047] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.302053] HDA Intel 0000:00:1b.0: EARLY resume
[18446744059.302105] pcieport 0000:00:1c.0: EARLY resume
[18446744059.302138] pcieport 0000:00:1c.0: restoring config space at offse=
t 0x7 (was 0xf0, writing 0x200000f0)
[18446744059.302152] pcieport 0000:00:1c.0: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.302185] pcieport 0000:00:1c.3: EARLY resume
[18446744059.302226] pcieport 0000:00:1c.3: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.302260] pcieport 0000:00:1c.4: EARLY resume
[18446744059.302281] pcieport 0000:00:1c.4: restoring config space at offse=
t 0xf (was 0x100, writing 0x4010b)
[18446744059.302294] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x9 (was 0x10001, writing 0x1fff1)
[18446744059.302301] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x8 (was 0x0, writing 0xf240f240)
[18446744059.302307] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x7 (was 0x0, writing 0x200000f0)
[18446744059.302318] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x3 (was 0x810000, writing 0x810010)
[18446744059.302326] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x1 (was 0x100000, writing 0x100507)
[18446744059.302360] ehci_hcd 0000:00:1d.0: EARLY resume
[18446744059.302377] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.302398] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728400)
[18446744059.302407] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.304044] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.306039] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.306044] pci 0000:00:1e.0: EARLY resume
[18446744059.306082] pci 0000:00:1f.0: EARLY resume
[18446744059.306121] ahci 0000:00:1f.2: EARLY resume
[18446744059.306159] ahci 0000:00:1f.2: restoring config space at offset 0x=
1 (was 0x2b00007, writing 0x2b00407)
[18446744059.306192] i801_smbus 0000:00:1f.3: EARLY resume
[18446744059.306221] pci 0000:00:1f.6: EARLY resume
[18446744059.306236] pci 0000:00:1f.6: restoring config space at offset 0xf=
 (was 0x400, writing 0x40b)
[18446744059.306260] pci 0000:00:1f.6: restoring config space at offset 0x1=
 (was 0x100000, writing 0x100002)
[18446744059.306276] iwlagn 0000:02:00.0: EARLY resume
[18446744059.306406] pcspkr pcspkr: EARLY resume
[18446744059.306408] platform microcode: EARLY resume
[18446744059.306412] input input0: EARLY type resume
[18446744059.306414] input input1: EARLY type resume
[18446744059.306417] input input2: EARLY type resume
[18446744059.306466] i8042 i8042: EARLY resume
[18446744059.306469] atkbd serio0: EARLY resume
[18446744059.306471] psmouse serio1: EARLY resume
[18446744059.306474] input input3: EARLY type resume
[18446744059.306478] input input4: EARLY type resume
[18446744059.306481] psmouse serio2: EARLY resume
[18446744059.306483] input input5: EARLY type resume
[18446744059.306486] platform regulatory.0: EARLY resume
[18446744059.306489] serial8250 serial8250: EARLY resume
[18446744059.306493] i2c i2c-0: EARLY resume
[18446744059.306495] usb usb1: EARLY type resume
[18446744059.306498] usb usb2: EARLY type resume
[18446744059.306504] thinkpad_acpi thinkpad_acpi: EARLY resume
[18446744059.306507] thinkpad_hwmon thinkpad_hwmon: EARLY resume
[18446744059.306512] input input6: EARLY type resume
[18446744059.306515] usb 1-1: EARLY type resume
[18446744059.306518] usb 2-1: EARLY type resume
[18446744059.306521] usb 1-1.3: EARLY type resume
[18446744059.306524] usb 1-1.6: EARLY type resume
[18446744059.306527] input input7: EARLY type resume
[18446744059.306530] input input8: EARLY type resume
[18446744059.306546] i2c i2c-1: EARLY resume
[18446744059.306548] i2c i2c-2: EARLY resume
[18446744059.306551] i2c i2c-3: EARLY resume
[18446744059.306553] i2c i2c-4: EARLY resume
[18446744059.306556] input input9: EARLY type resume
[18446744059.306559] PM: early resume of devices complete after 17.476 msecs
[18446744059.306619] pci 0000:ff:00.0: resume
[18446744059.306631] pci 0000:ff:00.1: resume
[18446744059.306641] pci 0000:ff:02.0: resume
[18446744059.306657] pci 0000:ff:02.1: resume
[18446744059.306670] pci 0000:ff:02.2: resume
[18446744059.306686] pci 0000:ff:02.3: resume
[18446744059.306717] agpgart-intel 0000:00:00.0: resume
[18446744059.306733] i915 0000:00:02.0: resume
[18446744059.306743] pci 0000:00:16.0: resume
[18446744059.306754] serial 0000:00:16.3: resume
[18446744059.306771] e1000e 0000:00:19.0: resume
[18446744059.306781] ehci_hcd 0000:00:1a.0: resume
[18446744059.306795] HDA Intel 0000:00:1b.0: resume
[18446744059.306814] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.306819] pcieport 0000:00:1c.0: resume
[18446744059.306843] pcieport 0000:00:1c.3: resume
[18446744059.306853] e1000e 0000:00:19.0: wake-up capability disabled by AC=
PI
[18446744059.306859] e1000e 0000:00:19.0: PME# disabled
[18446744059.306861] pcieport 0000:00:1c.4: resume
[18446744059.306882] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, lo=
w) -> IRQ 17
[18446744059.306893] HDA Intel 0000:00:1b.0: setting latency timer to 64
[18446744059.306961] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.306982] i915 0000:00:02.0: setting latency timer to 64
[18446744059.306999] HDA Intel 0000:00:1b.0: irq 44 for MSI/MSI-X
[18446744059.307062] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[18446744059.307093] ehci_hcd 0000:00:1d.0: resume
[18446744059.307144] pci 0000:00:1e.0: resume
[18446744059.307153] pci 0000:00:1e.0: setting latency timer to 64
[18446744059.307172] pci 0000:00:1f.0: resume
[18446744059.307189] ahci 0000:00:1f.2: resume
[18446744059.307205] ahci 0000:00:1f.2: setting latency timer to 64
[18446744059.307288] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.307382] i801_smbus 0000:00:1f.3: resume
[18446744059.307395] pci 0000:00:1f.6: resume
[18446744059.307407] iwlagn 0000:02:00.0: resume
[18446744059.307456] scsi host0: legacy resume
[18446744059.307476] scsi host1: legacy resume
[18446744059.307492] scsi host2: legacy resume
[18446744059.307495] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.307503] ehci_hcd 0000:00:1a.0: PCI INT D -> GSI 23 (level, low=
) -> IRQ 23
[18446744059.307510] scsi host3: legacy resume
[18446744059.307513] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[18446744059.307530] scsi host4: legacy resume
[18446744059.307550] scsi host5: legacy resume
[18446744059.307622] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.307671] scsi target0:0:0: legacy resume
[18446744059.307680] sd 0:0:0:0: legacy resume
[18446744059.307683] sd 0:0:0:0: [sda] Starting disk
[18446744059.307697] usb usb1: type resume
[18446744059.307825] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.307837] ehci_hcd 0000:00:1d.0: PCI INT D -> GSI 19 (level, low=
) -> IRQ 19
[18446744059.307844] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[18446744059.307940] acpi LNXSYSTM:00: legacy resume
[18446744059.307942] processor LNXCPU:00: legacy resume
[18446744059.307946] processor LNXCPU:01: legacy resume
[18446744059.307947] processor LNXCPU:02: legacy resume
[18446744059.307949] processor LNXCPU:03: legacy resume
[18446744059.307951] processor LNXCPU:04: legacy resume
[18446744059.307953] processor LNXCPU:05: legacy resume
[18446744059.307954] processor LNXCPU:06: legacy resume
[18446744059.307956] processor LNXCPU:07: legacy resume
[18446744059.307958] acpi LNXSYBUS:00: legacy resume
[18446744059.307960] pci_link PNP0C0F:00: legacy resume
[18446744059.307963] pci_link PNP0C0F:01: legacy resume
[18446744059.307965] pci_link PNP0C0F:02: legacy resume
[18446744059.307977] pci_link PNP0C0F:03: legacy resume
[18446744059.307981] pci_link PNP0C0F:04: legacy resume
[18446744059.307983] pci_link PNP0C0F:05: legacy resume
[18446744059.307985] pci_link PNP0C0F:06: legacy resume
[18446744059.307987] pci_link PNP0C0F:07: legacy resume
[18446744059.307989] acpi PNP0C01:00: legacy resume
[18446744059.307991] button PNP0C0D:00: legacy resume
[18446744059.308389] button PNP0C0E:00: legacy resume
[18446744059.308392] pci_root PNP0A03:00: legacy resume
[18446744059.308394] acpi device:00: legacy resume
[18446744059.308395] pci_root PNP0A08:00: legacy resume
[18446744059.308398] video LNXVIDEO:00: legacy resume
[18446744059.308400] acpi device:01: legacy resume
[18446744059.308402] acpi device:02: legacy resume
[18446744059.308404] acpi device:03: legacy resume
[18446744059.308405] acpi device:04: legacy resume
[18446744059.308407] acpi device:05: legacy resume
[18446744059.308409] acpi device:06: legacy resume
[18446744059.308411] acpi device:07: legacy resume
[18446744059.308413] acpi device:08: legacy resume
[18446744059.308415] acpi device:09: legacy resume
[18446744059.308417] acpi PNP0C02:00: legacy resume
[18446744059.308418] acpi PNP0000:00: legacy resume
[18446744059.308420] acpi PNP0100:00: legacy resume
[18446744059.308422] acpi PNP0103:00: legacy resume
[18446744059.308424] acpi PNP0200:00: legacy resume
[18446744059.308426] acpi PNP0800:00: legacy resume
[18446744059.308428] acpi PNP0C04:00: legacy resume
[18446744059.308430] acpi PNP0B00:00: legacy resume
[18446744059.308431] acpi PNP0303:00: legacy resume
[18446744059.308434] acpi LEN0018:00: legacy resume
[18446744059.308435] acpi SMO1200:00: legacy resume
[18446744059.308437] ec PNP0C09:00: legacy resume
[18446744059.308444] power LNXPOWER:00: legacy resume
[18446744059.308645] battery PNP0C0A:00: legacy resume
[18446744059.310210] usb usb2: type resume
[18446744059.329109] ac ACPI0003:00: legacy resume
[18446744059.329328] thinkpad_hotkey IBM0068:00: legacy resume
[18446744059.329331] acpi device:0a: legacy resume
[18446744059.329333] acpi LNXVIDEO:01: legacy resume
[18446744059.329335] acpi device:0b: legacy resume
[18446744059.329337] acpi device:0c: legacy resume
[18446744059.329339] acpi device:0d: legacy resume
[18446744059.329340] acpi device:0e: legacy resume
[18446744059.329342] acpi device:0f: legacy resume
[18446744059.329344] acpi device:10: legacy resume
[18446744059.329346] acpi device:11: legacy resume
[18446744059.329348] acpi device:12: legacy resume
[18446744059.329350] acpi device:13: legacy resume
[18446744059.329351] acpi device:14: legacy resume
[18446744059.329353] acpi device:15: legacy resume
[18446744059.329355] acpi device:16: legacy resume
[18446744059.329356] acpi device:17: legacy resume
[18446744059.329358] acpi device:18: legacy resume
[18446744059.329360] acpi device:19: legacy resume
[18446744059.329362] acpi device:1a: legacy resume
[18446744059.329364] acpi device:1b: legacy resume
[18446744059.329366] acpi device:1c: legacy resume
[18446744059.329368] acpi device:1d: legacy resume
[18446744059.329370] acpi device:1e: legacy resume
[18446744059.329371] acpi device:1f: legacy resume
[18446744059.329374] acpi device:20: legacy resume
[18446744059.329376] acpi device:21: legacy resume
[18446744059.329378] acpi device:22: legacy resume
[18446744059.329380] acpi device:23: legacy resume
[18446744059.329382] acpi device:24: legacy resume
[18446744059.329384] acpi device:25: legacy resume
[18446744059.329385] acpi device:26: legacy resume
[18446744059.329387] acpi device:27: legacy resume
[18446744059.329389] acpi device:28: legacy resume
[18446744059.329391] acpi device:29: legacy resume
[18446744059.329393] acpi device:2a: legacy resume
[18446744059.329394] acpi device:2b: legacy resume
[18446744059.329396] acpi device:2c: legacy resume
[18446744059.329398] acpi device:2d: legacy resume
[18446744059.329400] acpi device:2e: legacy resume
[18446744059.329401] acpi device:2f: legacy resume
[18446744059.329403] acpi device:31: legacy resume
[18446744059.329405] acpi device:32: legacy resume
[18446744059.329407] acpi PNP0C02:01: legacy resume
[18446744059.329409] wmi PNP0C14:00: legacy resume
[18446744059.329411] acpi LNXTHERM:00: legacy resume
[18446744059.329413] thermal LNXTHERM:01: legacy resume
[18446744059.330112] button LNXPWRBN:00: legacy resume
[18446744059.330115] platform dock.0: resume
[18446744059.330117] platform dock.1: resume
[18446744059.330118] platform dock.2: resume
[18446744059.330125] system 00:00: legacy resume
[18446744059.330130] pnp 00:01: legacy resume
[18446744059.330132] pnp 00:02: legacy resume
[18446744059.330134] system 00:03: legacy resume
[18446744059.330137] pnp 00:04: legacy resume
[18446744059.330139] pnp 00:05: legacy resume
[18446744059.330141] pnp 00:06: legacy resume
[18446744059.330142] pnp 00:07: legacy resume
[18446744059.330144] rtc_cmos 00:08: legacy resume
[18446744059.330148] i8042 kbd 00:09: legacy resume
[18446744059.330150] i8042 aux 00:0a: legacy resume
[18446744059.330153] tpm_tis 00:0b: legacy resume
[18446744059.330156] system 00:0c: legacy resume
[18446744059.330161] pcspkr pcspkr: resume
[18446744059.330163] platform microcode: resume
[18446744059.330167] input input0: type resume
[18446744059.330169] input input1: type resume
[18446744059.330171] input input2: type resume
[18446744059.330279] i8042 i8042: resume
[18446744059.331004] atkbd serio0: resume
[18446744059.331078] psmouse serio1: resume
[18446744059.331081] input input3: type resume
[18446744059.347935] usb 1-1: type resume
[18446744059.351033] usb 2-1: type resume
[18446744059.449646] usb 1-1.3: type resume
[18446744059.449665] usb 1-1.6: type resume
[18446744059.522646] usb 1-1.3: reset full speed USB device using ehci_hcd =
and address 3
[18446744059.614448] ata2: SATA link down (SStatus 0 SControl 300)
[18446744059.616298] ata6: SATA link down (SStatus 0 SControl 300)
[18446744059.618296] ata5: SATA link down (SStatus 0 SControl 300)
[18446744059.680424] usb 1-1.6: reset high speed USB device using ehci_hcd =
and address 6
[18446744061.851094] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[18446744061.853531] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.853537] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.853542] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.858482] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.858488] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.858493] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.860651] ata1.00: configured for UDMA/100
[18446744061.875725] ata1.00: configured for UDMA/100
[18446744061.875731] ata1: EH complete
[18446744061.902961] input input4: type resume
[18446744061.902971] psmouse serio2: resume
[18446744061.902975] input input5: type resume
[18446744061.902998] platform regulatory.0: resume
[18446744061.903001] serial8250 serial8250: resume
[18446744061.903007] i2c i2c-0: resume
[18446744061.903031] thinkpad_acpi thinkpad_acpi: resume
[18446744061.906018] thinkpad_hwmon thinkpad_hwmon: resume
[18446744061.906022] rfkill rfkill0: legacy class resume
[18446744061.906024] leds tpacpi::thinklight: legacy class resume
[18446744061.906027] leds tpacpi::power: legacy class resume
[18446744061.906029] leds tpacpi:orange:batt: legacy class resume
[18446744061.906031] leds tpacpi:green:batt: legacy class resume
[18446744061.906034] leds tpacpi::dock_active: legacy class resume
[18446744061.906036] leds tpacpi::bay_active: legacy class resume
[18446744061.906038] leds tpacpi::dock_batt: legacy class resume
[18446744061.906040] leds tpacpi::unknown_led: legacy class resume
[18446744061.906042] leds tpacpi::standby: legacy class resume
[18446744061.906044] leds tpacpi::dock_status1: legacy class resume
[18446744061.906046] leds tpacpi::dock_status2: legacy class resume
[18446744061.906048] leds tpacpi::unknown_led2: legacy class resume
[18446744061.906050] leds tpacpi::unknown_led3: legacy class resume
[18446744061.906052] leds tpacpi::thinkvantage: legacy class resume
[18446744061.906054] input input6: type resume
[18446744061.906060] ieee80211 phy0: legacy class resume
[18446744061.906073] rfkill rfkill1: legacy class resume
[18446744061.906093] input input7: type resume
[18446744061.906096] input input8: type resume
[18446744061.906130] drm controlD64: legacy class resume
[18446744061.906132] drm card0: legacy class resume
[18446744061.906134] i2c i2c-1: resume
[18446744061.906136] drm card0-VGA-1: legacy class resume
[18446744061.906137] i2c i2c-2: resume
[18446744061.906139] drm card0-LVDS-1: legacy class resume
[18446744061.906141] i2c i2c-3: resume
[18446744061.906143] drm card0-HDMI Type A-1: legacy class resume
[18446744061.906145] drm card0-DisplayPort-1: legacy class resume
[18446744061.906146] i2c i2c-4: resume
[18446744061.906149] backlight acpi_video0: legacy class resume
[18446744061.906152] input input9: type resume
[18446744061.906156] PM: resume of devices complete after 2604.524 msecs
[18446744061.906171] usb 1-1.6: completing type resume
[18446744061.906174] usb 1-1.3: completing type resume
[18446744061.906176] usb 2-1: completing type resume
[18446744061.906178] usb 1-1: completing type resume
[18446744061.906182] thinkpad_hwmon thinkpad_hwmon: completing resume
[18446744061.906184] thinkpad_acpi thinkpad_acpi: completing resume
[18446744061.906188] usb usb2: completing type resume
[18446744061.906191] usb usb1: completing type resume
[18446744061.906193] serial8250 serial8250: completing resume
[18446744061.906195] platform regulatory.0: completing resume
[18446744061.906202] i8042 i8042: completing resume
[18446744061.906288] platform microcode: completing resume
[18446744061.906289] pcspkr pcspkr: completing resume
[18446744061.906297] iwlagn 0000:02:00.0: completing resume
[18446744061.906299] pci 0000:00:1f.6: completing resume
[18446744061.906301] i801_smbus 0000:00:1f.3: completing resume
[18446744061.906303] ahci 0000:00:1f.2: completing resume
[18446744061.906305] pci 0000:00:1f.0: completing resume
[18446744061.906307] pci 0000:00:1e.0: completing resume
[18446744061.906308] ehci_hcd 0000:00:1d.0: completing resume
[18446744061.906311] pcieport 0000:00:1c.4: completing resume
[18446744061.906313] pcieport 0000:00:1c.3: completing resume
[18446744061.906315] pcieport 0000:00:1c.0: completing resume
[18446744061.906317] HDA Intel 0000:00:1b.0: completing resume
[18446744061.906319] ehci_hcd 0000:00:1a.0: completing resume
[18446744061.906321] e1000e 0000:00:19.0: completing resume
[18446744061.906323] serial 0000:00:16.3: completing resume
[18446744061.906333] pci 0000:00:16.0: completing resume
[18446744061.906336] i915 0000:00:02.0: completing resume
[18446744061.906339] agpgart-intel 0000:00:00.0: completing resume
[18446744061.906342] pci 0000:ff:02.3: completing resume
[18446744061.906345] pci 0000:ff:02.2: completing resume
[18446744061.906347] pci 0000:ff:02.1: completing resume
[18446744061.906350] pci 0000:ff:02.0: completing resume
[18446744061.906352] pci 0000:ff:00.1: completing resume
[18446744061.906354] pci 0000:ff:00.0: completing resume
[18446744061.906357] platform dock.2: completing resume
[18446744061.906360] platform dock.1: completing resume
[18446744061.906362] platform dock.0: completing resume
[18446744061.906492] PM: Finishing wakeup.
[18446744061.906493] Restarting tasks ... done.
[18446744061.931757] video LNXVIDEO:00: Restoring backlight state
[18446744062.552933] usb 1-1.4: new full speed USB device using ehci_hcd an=
d address 8
[18446744062.642028] PM: Adding info for usb:1-1.4
[18446744062.642397] PM: Adding info for usb:1-1.4:1.0
[18446744062.642754] PM: Adding info for No Bus:hci0
[18446744062.642790] PM: Adding info for No Bus:rfkill3
[18446744062.642826] PM: Adding info for No Bus:ep_81
[18446744062.642838] PM: Adding info for No Bus:ep_82
[18446744062.642850] PM: Adding info for No Bus:ep_02
[18446744062.642864] PM: Adding info for usb:1-1.4:1.1
[18446744062.642892] PM: Adding info for No Bus:ep_83
[18446744062.642903] PM: Adding info for No Bus:ep_03
[18446744062.642918] PM: Adding info for usb:1-1.4:1.2
[18446744062.642960] PM: Adding info for No Bus:ep_84
[18446744062.642973] PM: Adding info for No Bus:ep_04
[18446744062.642988] PM: Adding info for usb:1-1.4:1.3
[18446744062.643028] PM: Adding info for No Bus:ep_00
[18446744062.965737] Bluetooth: L2CAP ver 2.14
[18446744062.965740] Bluetooth: L2CAP socket layer initialized
[18446744063.039141] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[18446744063.076608] Bridge firewalling registered
[18446744063.076798] PM: Adding info for No Bus:pan0
[18446744063.092166] Bluetooth: SCO (Voice Link) ver 0.6
[18446744063.092169] Bluetooth: SCO socket layer initialized
[18446744063.171539] Bluetooth: RFCOMM TTY layer initialized
[18446744063.171547] Bluetooth: RFCOMM socket layer initialized
[18446744063.171550] Bluetooth: RFCOMM ver 1.11
[  918.136061] usb 1-1.4: USB disconnect, address 8
[  918.136094] btusb_intr_complete: hci0 urb ffff8801300eab40 failed to res=
ubmit (19)
[  918.136175] btusb_bulk_complete: hci0 urb ffff8801300eacc0 failed to res=
ubmit (19)
[  918.136181] btusb_bulk_complete: hci0 urb ffff8801300eae40 failed to res=
ubmit (19)
[  918.136401] PM: Removing info for No Bus:ep_81
[  918.136418] PM: Removing info for No Bus:ep_82
[  918.136425] PM: Removing info for No Bus:ep_02
[  918.136433] PM: Removing info for usb:1-1.4:1.0
[  918.136461] btusb_send_frame: hci0 urb ffff88010d919180 submission failed
[  918.335083] PM: Syncing filesystems ...=20
[  918.385759] PM: Removing info for No Bus:rfkill3
[  918.424745] PM: Removing info for No Bus:hci0
[  918.424836] PM: Removing info for No Bus:ep_83
[  918.424848] PM: Removing info for No Bus:ep_03
[  918.424857] PM: Removing info for usb:1-1.4:1.1
[  918.424877] PM: Removing info for No Bus:ep_84
[  918.424886] PM: Removing info for No Bus:ep_04
[  918.424895] PM: Removing info for usb:1-1.4:1.2
[  918.424916] PM: Removing info for usb:1-1.4:1.3
[  918.424937] PM: Removing info for No Bus:ep_00
[  918.424951] PM: Removing info for usb:1-1.4
[  918.479645] done.
[  918.479649] PM: Preparing system for mem sleep
[  918.578068] Freezing user space processes ... (elapsed 0.01 seconds) don=
e.
[  918.589350] Freezing remaining freezable tasks ... (elapsed 0.01 seconds=
) done.
[  918.600406] PM: Entering mem sleep
[  918.600525] Suspending console(s) (use no_console_suspend to debug)
[  918.600552] platform dock.0: preparing suspend
[  918.600554] platform dock.1: preparing suspend
[  918.600556] platform dock.2: preparing suspend
[  918.600558] pci 0000:ff:00.0: preparing suspend
[  918.600560] pci 0000:ff:00.1: preparing suspend
[  918.600562] pci 0000:ff:02.0: preparing suspend
[  918.600564] pci 0000:ff:02.1: preparing suspend
[  918.600565] pci 0000:ff:02.2: preparing suspend
[  918.600567] pci 0000:ff:02.3: preparing suspend
[  918.600570] agpgart-intel 0000:00:00.0: preparing suspend
[  918.600572] i915 0000:00:02.0: preparing suspend
[  918.600574] pci 0000:00:16.0: preparing suspend
[  918.600576] serial 0000:00:16.3: preparing suspend
[  918.600578] e1000e 0000:00:19.0: preparing suspend, may wakeup
[  918.600581] ehci_hcd 0000:00:1a.0: preparing suspend
[  918.600583] HDA Intel 0000:00:1b.0: preparing suspend
[  918.600585] pcieport 0000:00:1c.0: preparing suspend
[  918.600587] pcieport 0000:00:1c.3: preparing suspend
[  918.600589] pcieport 0000:00:1c.4: preparing suspend
[  918.600591] ehci_hcd 0000:00:1d.0: preparing suspend
[  918.600593] pci 0000:00:1e.0: preparing suspend
[  918.600594] pci 0000:00:1f.0: preparing suspend
[  918.600596] ahci 0000:00:1f.2: preparing suspend
[  918.600598] i801_smbus 0000:00:1f.3: preparing suspend
[  918.600600] pci 0000:00:1f.6: preparing suspend
[  918.600603] iwlagn 0000:02:00.0: preparing suspend
[  918.600610] pcspkr pcspkr: preparing suspend
[  918.600612] platform microcode: preparing suspend
[  918.600700] i8042 i8042: preparing suspend
[  918.600710] platform regulatory.0: preparing suspend
[  918.600712] serial8250 serial8250: preparing suspend
[  918.600716] usb usb1: preparing type suspend, may wakeup
[  918.600719] usb usb2: preparing type suspend, may wakeup
[  918.600726] thinkpad_acpi thinkpad_acpi: preparing suspend
[  918.600728] thinkpad_hwmon thinkpad_hwmon: preparing suspend
[  918.600735] usb 1-1: preparing type suspend
[  918.600737] usb 2-1: preparing type suspend
[  918.600740] usb 1-1.3: preparing type suspend
[  918.600743] usb 1-1.6: preparing type suspend
[  918.600776] input input9: type suspend
[  918.600780] backlight acpi_video0: legacy class suspend
[  918.600783] i2c i2c-4: suspend
[  918.600786] drm card0-DisplayPort-1: legacy class suspend
[  918.600788] drm card0-HDMI Type A-1: legacy class suspend
[  918.600790] i2c i2c-3: suspend
[  918.600792] drm card0-LVDS-1: legacy class suspend
[  918.600794] i2c i2c-2: suspend
[  918.600795] drm card0-VGA-1: legacy class suspend
[  918.600797] i2c i2c-1: suspend
[  918.600800] drm card0: legacy class suspend
[  918.600801] drm controlD64: legacy class suspend
[  918.600847] input input8: type suspend
[  918.600849] input input7: type suspend
[  918.600859] rfkill rfkill1: legacy class suspend
[  918.600861] ieee80211 phy0: legacy class suspend
[  918.600958] usb 1-1.6: type suspend
[  918.600966] usb 1-1.3: type suspend
[  918.612365] usb 2-1: type suspend
[  918.612370] input input6: type suspend
[  918.612376] leds tpacpi::thinkvantage: legacy class suspend
[  918.612380] leds tpacpi::unknown_led3: legacy class suspend
[  918.612385] leds tpacpi::unknown_led2: legacy class suspend
[  918.612389] leds tpacpi::dock_status2: legacy class suspend
[  918.612393] leds tpacpi::dock_status1: legacy class suspend
[  918.612397] leds tpacpi::standby: legacy class suspend
[  918.612401] leds tpacpi::unknown_led: legacy class suspend
[  918.612405] leds tpacpi::dock_batt: legacy class suspend
[  918.612409] leds tpacpi::bay_active: legacy class suspend
[  918.612413] leds tpacpi::dock_active: legacy class suspend
[  918.612417] leds tpacpi:green:batt: legacy class suspend
[  918.612421] usb 1-1: type suspend
[  918.612425] leds tpacpi:orange:batt: legacy class suspend
[  918.612429] leds tpacpi::power: legacy class suspend
[  918.612433] leds tpacpi::thinklight: legacy class suspend
[  918.612438] rfkill rfkill0: legacy class suspend
[  918.612443] thinkpad_hwmon thinkpad_hwmon: suspend
[  918.612449] thinkpad_acpi thinkpad_acpi: suspend
[  918.612479] usb usb2: type suspend, may wakeup
[  918.612481] i2c i2c-0: suspend
[  918.612486] serial8250 serial8250: suspend
[  918.612489] platform regulatory.0: suspend
[  918.612492] usb usb1: type suspend, may wakeup
[  918.612494] input input5: type suspend
[  918.612498] psmouse serio2: suspend
[  918.783275] input input4: type suspend
[  918.783300] sd 0:0:0:0: legacy suspend
[  918.783307] input input3: type suspend
[  918.783311] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[  918.783319] psmouse serio1: suspend
[  918.824626] sd 0:0:0:0: [sda] Stopping disk
[  918.837381] atkbd serio0: suspend
[  918.838187] i8042 i8042: suspend
[  918.838747] scsi host5: legacy suspend
[  918.838751] scsi host4: legacy suspend
[  918.838754] scsi host3: legacy suspend
[  918.838757] scsi host2: legacy suspend
[  918.838760] scsi host1: legacy suspend
[  918.838889] input input2: type suspend
[  918.838891] input input1: type suspend
[  918.838893] input input0: type suspend
[  918.838897] platform microcode: suspend
[  918.838899] pcspkr pcspkr: suspend
[  918.838910] system 00:0c: legacy suspend
[  918.838912] ACPI handle has no context!
[  918.838916] tpm_tis 00:0b: legacy suspend
[  919.030611] i8042 aux 00:0a: legacy suspend
[  919.030623] i8042 kbd 00:09: legacy suspend
[  919.030634] rtc_cmos 00:08: legacy suspend, may wakeup
[  919.030648] pnp 00:07: legacy suspend
[  919.030651] pnp 00:06: legacy suspend
[  919.030653] pnp 00:05: legacy suspend
[  919.030656] pnp 00:04: legacy suspend
[  919.030659] system 00:03: legacy suspend
[  919.030671] pnp 00:02: legacy suspend
[  919.030673] pnp 00:01: legacy suspend
[  919.030675] system 00:00: legacy suspend
[  919.030695] iwlagn 0000:02:00.0: suspend
[  919.030717] platform dock.2: suspend
[  919.030719] platform dock.1: suspend
[  919.030722] platform dock.0: suspend
[  919.030725] button LNXPWRBN:00: legacy suspend
[  919.030729] thermal LNXTHERM:01: legacy suspend
[  919.030732] acpi LNXTHERM:00: legacy suspend
[  919.030735] wmi PNP0C14:00: legacy suspend
[  919.030738] acpi PNP0C02:01: legacy suspend
[  919.030740] acpi device:32: legacy suspend
[  919.030743] acpi device:31: legacy suspend
[  919.030745] acpi device:2f: legacy suspend
[  919.030749] acpi device:2e: legacy suspend
[  919.030750] acpi device:2d: legacy suspend
[  919.030753] acpi device:2c: legacy suspend
[  919.030755] acpi device:2b: legacy suspend
[  919.030759] acpi device:2a: legacy suspend
[  919.030761] acpi device:29: legacy suspend
[  919.030764] acpi device:28: legacy suspend
[  919.030766] acpi device:27: legacy suspend
[  919.030769] acpi device:26: legacy suspend
[  919.030771] acpi device:25: legacy suspend
[  919.030773] acpi device:24: legacy suspend
[  919.030777] acpi device:23: legacy suspend
[  919.030779] acpi device:22: legacy suspend
[  919.030782] acpi device:21: legacy suspend
[  919.030786] acpi device:20: legacy suspend
[  919.030788] acpi device:1f: legacy suspend
[  919.030790] acpi device:1e: legacy suspend
[  919.030793] acpi device:1d: legacy suspend
[  919.030795] acpi device:1c: legacy suspend
[  919.030797] acpi device:1b: legacy suspend
[  919.030799] acpi device:1a: legacy suspend
[  919.030801] acpi device:19: legacy suspend
[  919.030804] acpi device:18: legacy suspend
[  919.030806] acpi device:17: legacy suspend
[  919.030809] acpi device:16: legacy suspend
[  919.030812] acpi device:15: legacy suspend
[  919.030815] acpi device:14: legacy suspend
[  919.030817] pci 0000:00:1f.6: suspend
[  919.030819] acpi device:13: legacy suspend
[  919.030821] acpi device:12: legacy suspend
[  919.030823] i801_smbus 0000:00:1f.3: suspend
[  919.030825] acpi device:11: legacy suspend
[  919.030827] acpi device:10: legacy suspend
[  919.030829] acpi device:0f: legacy suspend
[  919.030831] acpi device:0e: legacy suspend
[  919.030833] acpi device:0d: legacy suspend
[  919.030835] acpi device:0c: legacy suspend
[  919.030837] acpi device:0b: legacy suspend
[  919.030839] acpi LNXVIDEO:01: legacy suspend
[  919.030841] acpi device:0a: legacy suspend
[  919.030843] thinkpad_hotkey IBM0068:00: legacy suspend
[  919.030846] ac ACPI0003:00: legacy suspend
[  919.030848] battery PNP0C0A:00: legacy suspend
[  919.030850] power LNXPOWER:00: legacy suspend
[  919.030853] ec PNP0C09:00: legacy suspend
[  919.030860] acpi SMO1200:00: legacy suspend
[  919.030862] acpi LEN0018:00: legacy suspend
[  919.030864] acpi PNP0303:00: legacy suspend
[  919.030867] acpi PNP0B00:00: legacy suspend
[  919.030868] acpi PNP0C04:00: legacy suspend
[  919.030870] acpi PNP0800:00: legacy suspend
[  919.030872] acpi PNP0200:00: legacy suspend
[  919.030873] acpi PNP0103:00: legacy suspend
[  919.030875] acpi PNP0100:00: legacy suspend
[  919.030877] acpi PNP0000:00: legacy suspend
[  919.030879] acpi PNP0C02:00: legacy suspend
[  919.030881] acpi device:09: legacy suspend
[  919.030882] acpi device:08: legacy suspend
[  919.030884] acpi device:07: legacy suspend
[  919.030885] acpi device:06: legacy suspend
[  919.030887] acpi device:05: legacy suspend
[  919.030888] acpi device:04: legacy suspend
[  919.030890] acpi device:03: legacy suspend
[  919.030892] acpi device:02: legacy suspend
[  919.030893] acpi device:01: legacy suspend
[  919.030896] video LNXVIDEO:00: legacy suspend
[  919.030900] pci_root PNP0A08:00: legacy suspend
[  919.030901] acpi device:00: legacy suspend
[  919.030903] pci_root PNP0A03:00: legacy suspend
[  919.030905] button PNP0C0E:00: legacy suspend
[  919.030907] button PNP0C0D:00: legacy suspend
[  919.030909] acpi PNP0C01:00: legacy suspend
[  919.030911] pci_link PNP0C0F:07: legacy suspend
[  919.030912] pci_link PNP0C0F:06: legacy suspend
[  919.030914] pci_link PNP0C0F:05: legacy suspend
[  919.030916] pci_link PNP0C0F:04: legacy suspend
[  919.030918] pci_link PNP0C0F:03: legacy suspend
[  919.030920] pci_link PNP0C0F:02: legacy suspend
[  919.030922] pci_link PNP0C0F:01: legacy suspend
[  919.030924] pci 0000:00:1f.0: suspend
[  919.030927] pci_link PNP0C0F:00: legacy suspend
[  919.030928] pci 0000:00:1e.0: suspend
[  919.030931] acpi LNXSYBUS:00: legacy suspend
[  919.030933] ehci_hcd 0000:00:1d.0: suspend
[  919.030935] processor LNXCPU:07: legacy suspend
[  919.030940] processor LNXCPU:06: legacy suspend
[  919.030942] processor LNXCPU:05: legacy suspend
[  919.030945] processor LNXCPU:04: legacy suspend
[  919.030946] processor LNXCPU:03: legacy suspend
[  919.030949] processor LNXCPU:02: legacy suspend
[  919.030951] ehci_hcd 0000:00:1d.0: PCI INT D disabled
[  919.030953] processor LNXCPU:01: legacy suspend
[  919.030955] processor LNXCPU:00: legacy suspend
[  919.030960] acpi LNXSYSTM:00: legacy suspend
[  919.030962] pcieport 0000:00:1c.3: suspend
[  919.030966] pcieport 0000:00:1c.0: suspend
[  919.030970] HDA Intel 0000:00:1b.0: suspend
[  919.030993] HDA Intel 0000:00:1b.0: PCI INT B disabled
[  919.031061] ehci_hcd 0000:00:1a.0: suspend
[  919.031074] ehci_hcd 0000:00:1a.0: PCI INT D disabled
[  919.031078] e1000e 0000:00:19.0: suspend, may wakeup
[  919.031092] serial 0000:00:16.3: suspend
[  919.031135] ACPI handle has no context!
[  919.031147] pci 0000:00:16.0: suspend
[  919.031152] i915 0000:00:02.0: suspend
[  919.031405] agpgart-intel 0000:00:00.0: suspend
[  919.031417] pci 0000:ff:02.3: suspend
[  919.031421] pci 0000:ff:02.2: suspend
[  919.031424] pci 0000:ff:02.1: suspend
[  919.031427] pci 0000:ff:02.0: suspend
[  919.031431] pci 0000:ff:00.1: suspend
[  919.031434] pci 0000:ff:00.0: suspend
[  919.034613] async/9:30996 freeing invalid memtype bb77e000-bb781000
[  919.041617] pcieport 0000:00:1c.4: suspend
[  919.045653] i915 0000:00:02.0: power state changed by ACPI to D3
[  919.201830] scsi target0:0:0: legacy suspend
[  919.201835] scsi host0: legacy suspend
[  919.201840] ahci 0000:00:1f.2: suspend
[  919.212987] e1000e 0000:00:19.0: PME# enabled
[  919.212998] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
[  919.269040] PM: suspend of devices complete after 669.540 msecs
[  919.269077] input input9: LATE type suspend
[  919.269080] i2c i2c-4: LATE suspend
[  919.269082] i2c i2c-3: LATE suspend
[  919.269084] i2c i2c-2: LATE suspend
[  919.269086] i2c i2c-1: LATE suspend
[  919.269093] input input8: LATE type suspend
[  919.269095] input input7: LATE type suspend
[  919.269098] usb 1-1.6: LATE type suspend
[  919.269100] usb 1-1.3: LATE type suspend
[  919.269103] usb 2-1: LATE type suspend
[  919.269105] usb 1-1: LATE type suspend
[  919.269107] input input6: LATE type suspend
[  919.269110] thinkpad_hwmon thinkpad_hwmon: LATE suspend
[  919.269113] thinkpad_acpi thinkpad_acpi: LATE suspend
[  919.269116] usb usb2: LATE type suspend, may wakeup
[  919.269119] usb usb1: LATE type suspend, may wakeup
[  919.269121] i2c i2c-0: LATE suspend
[  919.269124] serial8250 serial8250: LATE suspend
[  919.269126] platform regulatory.0: LATE suspend
[  919.269128] input input5: LATE type suspend
[  919.269131] psmouse serio2: LATE suspend
[  919.269133] input input4: LATE type suspend
[  919.269136] input input3: LATE type suspend
[  919.269139] psmouse serio1: LATE suspend
[  919.269141] atkbd serio0: LATE suspend
[  919.269143] i8042 i8042: LATE suspend
[  919.269165] input input2: LATE type suspend
[  919.269168] input input1: LATE type suspend
[  919.269170] input input0: LATE type suspend
[  919.269173] platform microcode: LATE suspend
[  919.269175] pcspkr pcspkr: LATE suspend
[  919.269178] iwlagn 0000:02:00.0: LATE suspend
[  919.269181] pci 0000:00:1f.6: LATE suspend
[  919.269215] i801_smbus 0000:00:1f.3: LATE suspend
[  919.269217] ahci 0000:00:1f.2: LATE suspend
[  919.269220] pci 0000:00:1f.0: LATE suspend
[  919.269250] pci 0000:00:1e.0: LATE suspend
[  919.269280] ehci_hcd 0000:00:1d.0: LATE suspend
[  919.282198] ehci_hcd 0000:00:1d.0: power state changed by ACPI to D3
[  919.282203] pcieport 0000:00:1c.4: LATE suspend
[  919.282253] pcieport 0000:00:1c.3: LATE suspend
[  919.282302] pcieport 0000:00:1c.0: LATE suspend
[  919.282352] HDA Intel 0000:00:1b.0: LATE suspend
[  919.282355] ehci_hcd 0000:00:1a.0: LATE suspend
[  919.300143] ehci_hcd 0000:00:1a.0: power state changed by ACPI to D3
[  919.300148] e1000e 0000:00:19.0: LATE suspend, may wakeup
[  919.300151] serial 0000:00:16.3: LATE suspend
[  919.300153] pci 0000:00:16.0: LATE suspend
[  919.300188] i915 0000:00:02.0: LATE suspend
[  919.300191] agpgart-intel 0000:00:00.0: LATE suspend
[  919.300202] pci 0000:ff:02.3: LATE suspend
[  919.300211] pci 0000:ff:02.2: LATE suspend
[  919.300219] pci 0000:ff:02.1: LATE suspend
[  919.300227] pci 0000:ff:02.0: LATE suspend
[  919.300236] pci 0000:ff:00.1: LATE suspend
[  919.300244] pci 0000:ff:00.0: LATE suspend
[  919.300253] platform dock.2: LATE suspend
[  919.300255] platform dock.1: LATE suspend
[  919.300257] platform dock.0: LATE suspend
[  919.300264] PM: late suspend of devices complete after 31.280 msecs
[  919.310126] ACPI: Preparing to enter system sleep state S3
[  919.348096] PM: Saving platform NVS memory
[  919.481273] Disabling non-boot CPUs ...
[  919.594420] CPU 1 is now offline
[  919.611577] CPU 2 is now offline
[  919.728191] CPU 3 is now offline
[  919.728193] SMP alternatives: switching to UP code
[  919.731805] Extended CMOS year: 2000
[18446744058.743265] Back to C!
[18446744058.743268] PM: Restoring platform NVS memory
[18446744058.880642] Extended CMOS year: 2000
[18446744058.880661] Enabling non-boot CPUs ...
[18446744058.881055] SMP alternatives: switching to SMP code
[18446744058.884029] Booting Node 0 Processor 1 APIC 0x1
[18446744058.982963] CPU1 is up
[18446744058.983098] Booting Node 0 Processor 2 APIC 0x4
[18446744059.089885] CPU2 is up
[18446744059.090014] Booting Node 0 Processor 3 APIC 0x5
[18446744059.196717] CPU3 is up
[18446744059.198164] ACPI: Waking up from system sleep state S3
[18446744059.274480] platform dock.0: EARLY resume
[18446744059.274484] platform dock.1: EARLY resume
[18446744059.274486] platform dock.2: EARLY resume
[18446744059.274489] pci 0000:ff:00.0: EARLY resume
[18446744059.274503] pci 0000:ff:00.1: EARLY resume
[18446744059.274513] pci 0000:ff:02.0: EARLY resume
[18446744059.274523] pci 0000:ff:02.1: EARLY resume
[18446744059.274532] pci 0000:ff:02.2: EARLY resume
[18446744059.274542] pci 0000:ff:02.3: EARLY resume
[18446744059.274552] agpgart-intel 0000:00:00.0: EARLY resume
[18446744059.274567] i915 0000:00:02.0: EARLY resume
[18446744059.274581] i915 0000:00:02.0: restoring config space at offset 0x=
1 (was 0x900007, writing 0x900407)
[18446744059.274595] pci 0000:00:16.0: EARLY resume
[18446744059.274640] serial 0000:00:16.3: EARLY resume
[18446744059.274683] e1000e 0000:00:19.0: EARLY resume
[18446744059.274733] ehci_hcd 0000:00:1a.0: EARLY resume
[18446744059.274751] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.274772] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728000)
[18446744059.274781] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.285389] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.287398] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.287404] HDA Intel 0000:00:1b.0: EARLY resume
[18446744059.287455] pcieport 0000:00:1c.0: EARLY resume
[18446744059.287497] pcieport 0000:00:1c.0: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.287529] pcieport 0000:00:1c.3: EARLY resume
[18446744059.287570] pcieport 0000:00:1c.3: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.287603] pcieport 0000:00:1c.4: EARLY resume
[18446744059.287624] pcieport 0000:00:1c.4: restoring config space at offse=
t 0xf (was 0x100, writing 0x4010b)
[18446744059.287638] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x9 (was 0x10001, writing 0x1fff1)
[18446744059.287644] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x8 (was 0x0, writing 0xf240f240)
[18446744059.287651] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x7 (was 0x0, writing 0xf0)
[18446744059.287662] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x3 (was 0x810000, writing 0x810010)
[18446744059.287670] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x1 (was 0x100000, writing 0x100507)
[18446744059.287703] ehci_hcd 0000:00:1d.0: EARLY resume
[18446744059.287720] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.287740] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728400)
[18446744059.287750] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.289395] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.291391] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.291396] pci 0000:00:1e.0: EARLY resume
[18446744059.291434] pci 0000:00:1f.0: EARLY resume
[18446744059.291472] ahci 0000:00:1f.2: EARLY resume
[18446744059.291510] ahci 0000:00:1f.2: restoring config space at offset 0x=
1 (was 0x2b00007, writing 0x2b00407)
[18446744059.291543] i801_smbus 0000:00:1f.3: EARLY resume
[18446744059.291573] pci 0000:00:1f.6: EARLY resume
[18446744059.291588] pci 0000:00:1f.6: restoring config space at offset 0xf=
 (was 0x400, writing 0x40b)
[18446744059.291612] pci 0000:00:1f.6: restoring config space at offset 0x1=
 (was 0x100000, writing 0x100002)
[18446744059.291628] iwlagn 0000:02:00.0: EARLY resume
[18446744059.291701] iwlagn 0000:02:00.0: restoring config space at offset =
0x1 (was 0x100106, writing 0x100506)
[18446744059.291762] pcspkr pcspkr: EARLY resume
[18446744059.291764] platform microcode: EARLY resume
[18446744059.291768] input input0: EARLY type resume
[18446744059.291771] input input1: EARLY type resume
[18446744059.291773] input input2: EARLY type resume
[18446744059.291822] i8042 i8042: EARLY resume
[18446744059.291825] atkbd serio0: EARLY resume
[18446744059.291828] psmouse serio1: EARLY resume
[18446744059.291831] input input3: EARLY type resume
[18446744059.291835] input input4: EARLY type resume
[18446744059.291837] psmouse serio2: EARLY resume
[18446744059.291840] input input5: EARLY type resume
[18446744059.291843] platform regulatory.0: EARLY resume
[18446744059.291846] serial8250 serial8250: EARLY resume
[18446744059.291849] i2c i2c-0: EARLY resume
[18446744059.291852] usb usb1: EARLY type resume
[18446744059.291855] usb usb2: EARLY type resume
[18446744059.291861] thinkpad_acpi thinkpad_acpi: EARLY resume
[18446744059.291864] thinkpad_hwmon thinkpad_hwmon: EARLY resume
[18446744059.291868] input input6: EARLY type resume
[18446744059.291871] usb 1-1: EARLY type resume
[18446744059.291874] usb 2-1: EARLY type resume
[18446744059.291877] usb 1-1.3: EARLY type resume
[18446744059.291880] usb 1-1.6: EARLY type resume
[18446744059.291884] input input7: EARLY type resume
[18446744059.291886] input input8: EARLY type resume
[18446744059.291902] i2c i2c-1: EARLY resume
[18446744059.291905] i2c i2c-2: EARLY resume
[18446744059.291907] i2c i2c-3: EARLY resume
[18446744059.291910] i2c i2c-4: EARLY resume
[18446744059.291913] input input9: EARLY type resume
[18446744059.291916] PM: early resume of devices complete after 17.481 msecs
[18446744059.291980] pci 0000:ff:00.0: resume
[18446744059.291985] pci 0000:ff:00.1: resume
[18446744059.291988] pci 0000:ff:02.0: resume
[18446744059.291990] pci 0000:ff:02.1: resume
[18446744059.291993] pci 0000:ff:02.2: resume
[18446744059.291995] pci 0000:ff:02.3: resume
[18446744059.291999] agpgart-intel 0000:00:00.0: resume
[18446744059.292057] acpi LNXSYSTM:00: legacy resume
[18446744059.292059] processor LNXCPU:00: legacy resume
[18446744059.292065] processor LNXCPU:01: legacy resume
[18446744059.292067] processor LNXCPU:02: legacy resume
[18446744059.292069] processor LNXCPU:03: legacy resume
[18446744059.292070] processor LNXCPU:04: legacy resume
[18446744059.292072] processor LNXCPU:05: legacy resume
[18446744059.292074] processor LNXCPU:06: legacy resume
[18446744059.292076] processor LNXCPU:07: legacy resume
[18446744059.292078] acpi LNXSYBUS:00: legacy resume
[18446744059.292080] pci_link PNP0C0F:00: legacy resume
[18446744059.292082] pci_link PNP0C0F:01: legacy resume
[18446744059.292084] pci_link PNP0C0F:02: legacy resume
[18446744059.292086] pci_link PNP0C0F:03: legacy resume
[18446744059.292088] pci_link PNP0C0F:04: legacy resume
[18446744059.292090] pci_link PNP0C0F:05: legacy resume
[18446744059.292092] pci_link PNP0C0F:06: legacy resume
[18446744059.292094] pci_link PNP0C0F:07: legacy resume
[18446744059.292096] acpi PNP0C01:00: legacy resume
[18446744059.292098] button PNP0C0D:00: legacy resume
[18446744059.292505] button PNP0C0E:00: legacy resume
[18446744059.292510] pci_root PNP0A03:00: legacy resume
[18446744059.292512] acpi device:00: legacy resume
[18446744059.292514] pci_root PNP0A08:00: legacy resume
[18446744059.292516] video LNXVIDEO:00: legacy resume
[18446744059.292518] acpi device:01: legacy resume
[18446744059.292520] acpi device:02: legacy resume
[18446744059.292522] acpi device:03: legacy resume
[18446744059.292524] acpi device:04: legacy resume
[18446744059.292526] acpi device:05: legacy resume
[18446744059.292528] acpi device:06: legacy resume
[18446744059.292530] acpi device:07: legacy resume
[18446744059.292531] acpi device:08: legacy resume
[18446744059.292533] acpi device:09: legacy resume
[18446744059.292535] acpi PNP0C02:00: legacy resume
[18446744059.292537] acpi PNP0000:00: legacy resume
[18446744059.292539] acpi PNP0100:00: legacy resume
[18446744059.292541] acpi PNP0103:00: legacy resume
[18446744059.292543] acpi PNP0200:00: legacy resume
[18446744059.292544] acpi PNP0800:00: legacy resume
[18446744059.292546] acpi PNP0C04:00: legacy resume
[18446744059.292548] acpi PNP0B00:00: legacy resume
[18446744059.292550] acpi PNP0303:00: legacy resume
[18446744059.292551] acpi LEN0018:00: legacy resume
[18446744059.292553] acpi SMO1200:00: legacy resume
[18446744059.292555] ec PNP0C09:00: legacy resume
[18446744059.292562] power LNXPOWER:00: legacy resume
[18446744059.292763] battery PNP0C0A:00: legacy resume
[18446744059.298192] i915 0000:00:02.0: resume
[18446744059.298269] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.298383] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.298388] i915 0000:00:02.0: setting latency timer to 64
[18446744059.298607] pci 0000:00:16.0: resume
[18446744059.298610] serial 0000:00:16.3: resume
[18446744059.298615] e1000e 0000:00:19.0: resume
[18446744059.298622] e1000e 0000:00:19.0: wake-up capability disabled by AC=
PI
[18446744059.298627] e1000e 0000:00:19.0: PME# disabled
[18446744059.298700] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[18446744059.302095] ehci_hcd 0000:00:1a.0: resume
[18446744059.302128] HDA Intel 0000:00:1b.0: resume
[18446744059.302139] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, lo=
w) -> IRQ 17
[18446744059.302146] HDA Intel 0000:00:1b.0: setting latency timer to 64
[18446744059.302196] HDA Intel 0000:00:1b.0: irq 45 for MSI/MSI-X
[18446744059.302226] pcieport 0000:00:1c.0: resume
[18446744059.302229] pcieport 0000:00:1c.3: resume
[18446744059.302233] pcieport 0000:00:1c.4: resume
[18446744059.302236] ehci_hcd 0000:00:1d.0: resume
[18446744059.302262] pci 0000:00:1e.0: resume
[18446744059.302271] pci 0000:00:1e.0: setting latency timer to 64
[18446744059.302275] pci 0000:00:1f.0: resume
[18446744059.302277] ahci 0000:00:1f.2: resume
[18446744059.302287] ahci 0000:00:1f.2: setting latency timer to 64
[18446744059.302346] i801_smbus 0000:00:1f.3: resume
[18446744059.302349] pci 0000:00:1f.6: resume
[18446744059.302351] iwlagn 0000:02:00.0: resume
[18446744059.302362] scsi host0: legacy resume
[18446744059.302365] scsi host1: legacy resume
[18446744059.302367] scsi host2: legacy resume
[18446744059.302370] scsi host3: legacy resume
[18446744059.302373] scsi host4: legacy resume
[18446744059.302375] scsi host5: legacy resume
[18446744059.302378] scsi target0:0:0: legacy resume
[18446744059.302380] sd 0:0:0:0: legacy resume
[18446744059.302383] sd 0:0:0:0: [sda] Starting disk
[18446744059.304620] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.304733] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.304935] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.304946] ehci_hcd 0000:00:1d.0: PCI INT D -> GSI 19 (level, low=
) -> IRQ 19
[18446744059.304953] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[18446744059.304982] usb usb2: type resume
[18446744059.306000] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.306012] ehci_hcd 0000:00:1a.0: PCI INT D -> GSI 23 (level, low=
) -> IRQ 23
[18446744059.306018] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[18446744059.306047] usb usb1: type resume
[18446744059.312013] ac ACPI0003:00: legacy resume
[18446744059.312240] thinkpad_hotkey IBM0068:00: legacy resume
[18446744059.312244] acpi device:0a: legacy resume
[18446744059.312246] acpi LNXVIDEO:01: legacy resume
[18446744059.312248] acpi device:0b: legacy resume
[18446744059.312250] acpi device:0c: legacy resume
[18446744059.312252] acpi device:0d: legacy resume
[18446744059.312254] acpi device:0e: legacy resume
[18446744059.312255] acpi device:0f: legacy resume
[18446744059.312257] acpi device:10: legacy resume
[18446744059.312259] acpi device:11: legacy resume
[18446744059.312261] acpi device:12: legacy resume
[18446744059.312263] acpi device:13: legacy resume
[18446744059.312264] acpi device:14: legacy resume
[18446744059.312266] acpi device:15: legacy resume
[18446744059.312268] acpi device:16: legacy resume
[18446744059.312270] acpi device:17: legacy resume
[18446744059.312272] acpi device:18: legacy resume
[18446744059.312273] acpi device:19: legacy resume
[18446744059.312275] acpi device:1a: legacy resume
[18446744059.312277] acpi device:1b: legacy resume
[18446744059.312279] acpi device:1c: legacy resume
[18446744059.312281] acpi device:1d: legacy resume
[18446744059.312292] acpi device:1e: legacy resume
[18446744059.312294] acpi device:1f: legacy resume
[18446744059.312296] acpi device:20: legacy resume
[18446744059.312298] acpi device:21: legacy resume
[18446744059.312300] acpi device:22: legacy resume
[18446744059.312302] acpi device:23: legacy resume
[18446744059.312304] acpi device:24: legacy resume
[18446744059.312306] acpi device:25: legacy resume
[18446744059.312308] acpi device:26: legacy resume
[18446744059.312309] acpi device:27: legacy resume
[18446744059.312311] acpi device:28: legacy resume
[18446744059.312313] acpi device:29: legacy resume
[18446744059.312315] acpi device:2a: legacy resume
[18446744059.312317] acpi device:2b: legacy resume
[18446744059.312318] acpi device:2c: legacy resume
[18446744059.312320] acpi device:2d: legacy resume
[18446744059.312322] acpi device:2e: legacy resume
[18446744059.312324] acpi device:2f: legacy resume
[18446744059.312325] acpi device:31: legacy resume
[18446744059.312327] acpi device:32: legacy resume
[18446744059.312329] acpi PNP0C02:01: legacy resume
[18446744059.312331] wmi PNP0C14:00: legacy resume
[18446744059.312333] acpi LNXTHERM:00: legacy resume
[18446744059.312335] thermal LNXTHERM:01: legacy resume
[18446744059.313056] button LNXPWRBN:00: legacy resume
[18446744059.313058] platform dock.0: resume
[18446744059.313060] platform dock.1: resume
[18446744059.313062] platform dock.2: resume
[18446744059.313068] system 00:00: legacy resume
[18446744059.313073] pnp 00:01: legacy resume
[18446744059.313075] pnp 00:02: legacy resume
[18446744059.313077] system 00:03: legacy resume
[18446744059.313080] pnp 00:04: legacy resume
[18446744059.313082] pnp 00:05: legacy resume
[18446744059.313083] pnp 00:06: legacy resume
[18446744059.313085] pnp 00:07: legacy resume
[18446744059.313087] rtc_cmos 00:08: legacy resume
[18446744059.313091] i8042 kbd 00:09: legacy resume
[18446744059.313094] i8042 aux 00:0a: legacy resume
[18446744059.313096] tpm_tis 00:0b: legacy resume
[18446744059.313099] system 00:0c: legacy resume
[18446744059.313104] pcspkr pcspkr: resume
[18446744059.313106] platform microcode: resume
[18446744059.313110] input input0: type resume
[18446744059.313112] input input1: type resume
[18446744059.313114] input input2: type resume
[18446744059.313217] i8042 i8042: resume
[18446744059.314166] atkbd serio0: resume
[18446744059.314173] psmouse serio1: resume
[18446744059.314176] input input3: type resume
[18446744059.346173] usb 1-1: type resume
[18446744059.350238] usb 2-1: type resume
[18446744059.447983] usb 1-1.3: type resume
[18446744059.447990] usb 1-1.6: type resume
[18446744059.520974] usb 1-1.3: reset full speed USB device using ehci_hcd =
and address 3
[18446744059.608829] ata2: SATA link down (SStatus 0 SControl 300)
[18446744059.610680] ata6: SATA link down (SStatus 0 SControl 300)
[18446744059.612682] ata5: SATA link down (SStatus 0 SControl 300)
[18446744059.668731] usb 1-1.6: reset high speed USB device using ehci_hcd =
and address 6
[18446744061.795524] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[18446744061.798023] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.798029] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.798034] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.802945] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.802951] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.802956] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.805064] ata1.00: configured for UDMA/100
[18446744061.820092] ata1.00: configured for UDMA/100
[18446744061.820097] ata1: EH complete
[18446744061.842771] input input4: type resume
[18446744061.842777] psmouse serio2: resume
[18446744061.842784] input input5: type resume
[18446744061.842808] platform regulatory.0: resume
[18446744061.842812] serial8250 serial8250: resume
[18446744061.842821] i2c i2c-0: resume
[18446744061.842844] thinkpad_acpi thinkpad_acpi: resume
[18446744061.846140] thinkpad_hwmon thinkpad_hwmon: resume
[18446744061.846143] rfkill rfkill0: legacy class resume
[18446744061.846146] leds tpacpi::thinklight: legacy class resume
[18446744061.846148] leds tpacpi::power: legacy class resume
[18446744061.846150] leds tpacpi:orange:batt: legacy class resume
[18446744061.846153] leds tpacpi:green:batt: legacy class resume
[18446744061.846155] leds tpacpi::dock_active: legacy class resume
[18446744061.846157] leds tpacpi::bay_active: legacy class resume
[18446744061.846159] leds tpacpi::dock_batt: legacy class resume
[18446744061.846161] leds tpacpi::unknown_led: legacy class resume
[18446744061.846163] leds tpacpi::standby: legacy class resume
[18446744061.846165] leds tpacpi::dock_status1: legacy class resume
[18446744061.846167] leds tpacpi::dock_status2: legacy class resume
[18446744061.846169] leds tpacpi::unknown_led2: legacy class resume
[18446744061.846171] leds tpacpi::unknown_led3: legacy class resume
[18446744061.846173] leds tpacpi::thinkvantage: legacy class resume
[18446744061.846175] input input6: type resume
[18446744061.846181] ieee80211 phy0: legacy class resume
[18446744061.846194] rfkill rfkill1: legacy class resume
[18446744061.846214] input input7: type resume
[18446744061.846217] input input8: type resume
[18446744061.846252] drm controlD64: legacy class resume
[18446744061.846254] drm card0: legacy class resume
[18446744061.846256] i2c i2c-1: resume
[18446744061.846258] drm card0-VGA-1: legacy class resume
[18446744061.846260] i2c i2c-2: resume
[18446744061.846261] drm card0-LVDS-1: legacy class resume
[18446744061.846263] i2c i2c-3: resume
[18446744061.846265] drm card0-HDMI Type A-1: legacy class resume
[18446744061.846267] drm card0-DisplayPort-1: legacy class resume
[18446744061.846269] i2c i2c-4: resume
[18446744061.846272] backlight acpi_video0: legacy class resume
[18446744061.846275] input input9: type resume
[18446744061.846279] PM: resume of devices complete after 2559.199 msecs
[18446744061.846294] usb 1-1.6: completing type resume
[18446744061.846297] usb 1-1.3: completing type resume
[18446744061.846299] usb 2-1: completing type resume
[18446744061.846301] usb 1-1: completing type resume
[18446744061.846305] thinkpad_hwmon thinkpad_hwmon: completing resume
[18446744061.846307] thinkpad_acpi thinkpad_acpi: completing resume
[18446744061.846311] usb usb2: completing type resume
[18446744061.846313] usb usb1: completing type resume
[18446744061.846316] serial8250 serial8250: completing resume
[18446744061.846318] platform regulatory.0: completing resume
[18446744061.846329] i8042 i8042: completing resume
[18446744061.846421] platform microcode: completing resume
[18446744061.846423] pcspkr pcspkr: completing resume
[18446744061.846430] iwlagn 0000:02:00.0: completing resume
[18446744061.846433] pci 0000:00:1f.6: completing resume
[18446744061.846435] i801_smbus 0000:00:1f.3: completing resume
[18446744061.846437] ahci 0000:00:1f.2: completing resume
[18446744061.846439] pci 0000:00:1f.0: completing resume
[18446744061.846440] pci 0000:00:1e.0: completing resume
[18446744061.846442] ehci_hcd 0000:00:1d.0: completing resume
[18446744061.846444] pcieport 0000:00:1c.4: completing resume
[18446744061.846446] pcieport 0000:00:1c.3: completing resume
[18446744061.846449] pcieport 0000:00:1c.0: completing resume
[18446744061.846452] HDA Intel 0000:00:1b.0: completing resume
[18446744061.846454] ehci_hcd 0000:00:1a.0: completing resume
[18446744061.846457] e1000e 0000:00:19.0: completing resume
[18446744061.846460] serial 0000:00:16.3: completing resume
[18446744061.846463] pci 0000:00:16.0: completing resume
[18446744061.846465] i915 0000:00:02.0: completing resume
[18446744061.846467] agpgart-intel 0000:00:00.0: completing resume
[18446744061.846470] pci 0000:ff:02.3: completing resume
[18446744061.846471] pci 0000:ff:02.2: completing resume
[18446744061.846473] pci 0000:ff:02.1: completing resume
[18446744061.846475] pci 0000:ff:02.0: completing resume
[18446744061.846477] pci 0000:ff:00.1: completing resume
[18446744061.846478] pci 0000:ff:00.0: completing resume
[18446744061.846480] platform dock.2: completing resume
[18446744061.846482] platform dock.1: completing resume
[18446744061.846484] platform dock.0: completing resume
[18446744061.846586] PM: Finishing wakeup.
[18446744061.846587] Restarting tasks ...=20
[18446744061.866415] PM: Removing info for No Bus:pan0
[18446744061.868748] done.
[18446744061.868754] video LNXVIDEO:00: Restoring backlight state
[18446744062.552261] usb 1-1.4: new full speed USB device using ehci_hcd an=
d address 9
[18446744062.641435] PM: Adding info for usb:1-1.4
[18446744062.641544] PM: Adding info for usb:1-1.4:1.0
[18446744062.641883] PM: Adding info for No Bus:hci0
[18446744062.641916] PM: Adding info for No Bus:rfkill4
[18446744062.641953] PM: Adding info for No Bus:ep_81
[18446744062.641963] PM: Adding info for No Bus:ep_82
[18446744062.641973] PM: Adding info for No Bus:ep_02
[18446744062.641988] PM: Adding info for usb:1-1.4:1.1
[18446744062.642011] PM: Adding info for No Bus:ep_83
[18446744062.642021] PM: Adding info for No Bus:ep_03
[18446744062.642032] PM: Adding info for usb:1-1.4:1.2
[18446744062.642073] PM: Adding info for No Bus:ep_84
[18446744062.642084] PM: Adding info for No Bus:ep_04
[18446744062.642096] PM: Adding info for usb:1-1.4:1.3
[18446744062.642134] PM: Adding info for No Bus:ep_00
[18446744062.654645] PM: Adding info for No Bus:pan0
[   22.579818] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   26.854078] wlan0: deauthenticating from 00:05:4e:4d:82:6d by local choi=
ce (reason=3D3)
[   26.890975] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[   26.895069] wlan0: authenticated
[   26.899910] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[   26.909302] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[   26.909308] wlan0: associated
[   26.914967] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   37.595483] wlan0: no IPv6 routers present
[ 6511.287033] tun: Universal TUN/TAP device driver, 1.6
[ 6511.287038] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[ 6511.287155] PM: Adding info for No Bus:tun
[ 6511.288341] PM: Adding info for No Bus:tun0
[ 6511.289016] tun0: Disabled Privacy Extensions
[ 6511.452781] PM: Removing info for No Bus:tun0
[ 8679.988560] usb 1-1.4: USB disconnect, address 9
[ 8679.988591] btusb_intr_complete: hci0 urb ffff880121071300 failed to res=
ubmit (19)
[ 8679.988738] btusb_bulk_complete: hci0 urb ffff880121071780 failed to res=
ubmit (19)
[ 8679.988744] btusb_bulk_complete: hci0 urb ffff8801210713c0 failed to res=
ubmit (19)
[ 8679.988759] PM: Removing info for No Bus:ep_81
[ 8679.988782] PM: Removing info for No Bus:ep_82
[ 8679.988794] PM: Removing info for No Bus:ep_02
[ 8679.988806] PM: Removing info for usb:1-1.4:1.0
[ 8679.988846] btusb_send_frame: hci0 urb ffff8801300d1240 submission failed
[ 8680.237592] PM: Syncing filesystems ...=20
[ 8680.237907] PM: Removing info for No Bus:rfkill4
[ 8680.237976] PM: Removing info for No Bus:hci0
[ 8680.238105] PM: Removing info for No Bus:ep_83
[ 8680.238117] PM: Removing info for No Bus:ep_03
[ 8680.238127] PM: Removing info for usb:1-1.4:1.1
[ 8680.238153] PM: Removing info for No Bus:ep_84
[ 8680.238164] PM: Removing info for No Bus:ep_04
[ 8680.238176] PM: Removing info for usb:1-1.4:1.2
[ 8680.238201] PM: Removing info for usb:1-1.4:1.3
[ 8680.238223] PM: Removing info for No Bus:ep_00
[ 8680.238235] PM: Removing info for usb:1-1.4
[ 8680.391760] done.
[ 8680.391765] PM: Preparing system for mem sleep
[ 8680.513092] Freezing user space processes ... (elapsed 0.01 seconds) don=
e.
[ 8680.524358] Freezing remaining freezable tasks ... (elapsed 0.01 seconds=
) done.
[ 8680.535413] PM: Entering mem sleep
[ 8680.535529] Suspending console(s) (use no_console_suspend to debug)
[ 8680.535555] platform dock.0: preparing suspend
[ 8680.535557] platform dock.1: preparing suspend
[ 8680.535559] platform dock.2: preparing suspend
[ 8680.535562] pci 0000:ff:00.0: preparing suspend
[ 8680.535564] pci 0000:ff:00.1: preparing suspend
[ 8680.535565] pci 0000:ff:02.0: preparing suspend
[ 8680.535567] pci 0000:ff:02.1: preparing suspend
[ 8680.535569] pci 0000:ff:02.2: preparing suspend
[ 8680.535571] pci 0000:ff:02.3: preparing suspend
[ 8680.535574] agpgart-intel 0000:00:00.0: preparing suspend
[ 8680.535576] i915 0000:00:02.0: preparing suspend
[ 8680.535578] pci 0000:00:16.0: preparing suspend
[ 8680.535580] serial 0000:00:16.3: preparing suspend
[ 8680.535582] e1000e 0000:00:19.0: preparing suspend, may wakeup
[ 8680.535584] ehci_hcd 0000:00:1a.0: preparing suspend
[ 8680.535587] HDA Intel 0000:00:1b.0: preparing suspend
[ 8680.535589] pcieport 0000:00:1c.0: preparing suspend
[ 8680.535591] pcieport 0000:00:1c.3: preparing suspend
[ 8680.535592] pcieport 0000:00:1c.4: preparing suspend
[ 8680.535594] ehci_hcd 0000:00:1d.0: preparing suspend
[ 8680.535596] pci 0000:00:1e.0: preparing suspend
[ 8680.535597] pci 0000:00:1f.0: preparing suspend
[ 8680.535599] ahci 0000:00:1f.2: preparing suspend
[ 8680.535602] i801_smbus 0000:00:1f.3: preparing suspend
[ 8680.535604] pci 0000:00:1f.6: preparing suspend
[ 8680.535606] iwlagn 0000:02:00.0: preparing suspend
[ 8680.535613] pcspkr pcspkr: preparing suspend
[ 8680.535615] platform microcode: preparing suspend
[ 8680.535705] i8042 i8042: preparing suspend
[ 8680.535714] platform regulatory.0: preparing suspend
[ 8680.535716] serial8250 serial8250: preparing suspend
[ 8680.535721] usb usb1: preparing type suspend, may wakeup
[ 8680.535723] usb usb2: preparing type suspend, may wakeup
[ 8680.535730] thinkpad_acpi thinkpad_acpi: preparing suspend
[ 8680.535733] thinkpad_hwmon thinkpad_hwmon: preparing suspend
[ 8680.535739] usb 1-1: preparing type suspend
[ 8680.535741] usb 2-1: preparing type suspend
[ 8680.535744] usb 1-1.3: preparing type suspend
[ 8680.535747] usb 1-1.6: preparing type suspend
[ 8680.535781] input input9: type suspend
[ 8680.535785] backlight acpi_video0: legacy class suspend
[ 8680.535788] i2c i2c-4: suspend
[ 8680.535791] drm card0-DisplayPort-1: legacy class suspend
[ 8680.535793] drm card0-HDMI Type A-1: legacy class suspend
[ 8680.535795] i2c i2c-3: suspend
[ 8680.535796] drm card0-LVDS-1: legacy class suspend
[ 8680.535798] i2c i2c-2: suspend
[ 8680.535800] drm card0-VGA-1: legacy class suspend
[ 8680.535802] i2c i2c-1: suspend
[ 8680.535804] drm card0: legacy class suspend
[ 8680.535806] drm controlD64: legacy class suspend
[ 8680.535852] input input8: type suspend
[ 8680.535854] input input7: type suspend
[ 8680.535864] rfkill rfkill1: legacy class suspend
[ 8680.535866] ieee80211 phy0: legacy class suspend
[ 8680.535965] usb 1-1.6: type suspend
[ 8680.535973] usb 1-1.3: type suspend
[ 8680.571151] usb 2-1: type suspend
[ 8680.571153] input input6: type suspend
[ 8680.571158] leds tpacpi::thinkvantage: legacy class suspend
[ 8680.571161] leds tpacpi::unknown_led3: legacy class suspend
[ 8680.571163] leds tpacpi::unknown_led2: legacy class suspend
[ 8680.571166] leds tpacpi::dock_status2: legacy class suspend
[ 8680.571169] leds tpacpi::dock_status1: legacy class suspend
[ 8680.571171] leds tpacpi::standby: legacy class suspend
[ 8680.571174] leds tpacpi::unknown_led: legacy class suspend
[ 8680.571177] leds tpacpi::dock_batt: legacy class suspend
[ 8680.571179] leds tpacpi::bay_active: legacy class suspend
[ 8680.571182] leds tpacpi::dock_active: legacy class suspend
[ 8680.571185] leds tpacpi:green:batt: legacy class suspend
[ 8680.571187] leds tpacpi:orange:batt: legacy class suspend
[ 8680.571190] leds tpacpi::power: legacy class suspend
[ 8680.571192] leds tpacpi::thinklight: legacy class suspend
[ 8680.571195] rfkill rfkill0: legacy class suspend
[ 8680.571199] thinkpad_hwmon thinkpad_hwmon: suspend
[ 8680.571203] thinkpad_acpi thinkpad_acpi: suspend
[ 8680.571225] usb 1-1: type suspend
[ 8680.571227] i2c i2c-0: suspend
[ 8680.571232] serial8250 serial8250: suspend
[ 8680.571234] platform regulatory.0: suspend
[ 8680.571242] input input5: type suspend
[ 8680.571246] psmouse serio2: suspend
[ 8680.571293] usb usb2: type suspend, may wakeup
[ 8680.572000] usb usb1: type suspend, may wakeup
[ 8680.748679] input input4: type suspend
[ 8680.748702] sd 0:0:0:0: legacy suspend
[ 8680.748706] input input3: type suspend
[ 8680.748710] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[ 8680.748713] psmouse serio1: suspend
[ 8680.787383] sd 0:0:0:0: [sda] Stopping disk
[ 8680.805534] atkbd serio0: suspend
[ 8680.806159] i8042 i8042: suspend
[ 8680.807149] scsi host5: legacy suspend
[ 8680.807153] scsi host4: legacy suspend
[ 8680.807157] scsi host3: legacy suspend
[ 8680.807160] scsi host2: legacy suspend
[ 8680.807163] scsi host1: legacy suspend
[ 8680.807288] input input2: type suspend
[ 8680.807290] input input1: type suspend
[ 8680.807292] input input0: type suspend
[ 8680.807296] platform microcode: suspend
[ 8680.807298] pcspkr pcspkr: suspend
[ 8680.807309] system 00:0c: legacy suspend
[ 8680.807311] ACPI handle has no context!
[ 8680.807315] tpm_tis 00:0b: legacy suspend
[ 8680.998554] i8042 aux 00:0a: legacy suspend
[ 8680.998567] i8042 kbd 00:09: legacy suspend
[ 8680.998578] rtc_cmos 00:08: legacy suspend, may wakeup
[ 8680.998592] pnp 00:07: legacy suspend
[ 8680.998594] pnp 00:06: legacy suspend
[ 8680.998597] pnp 00:05: legacy suspend
[ 8680.998599] pnp 00:04: legacy suspend
[ 8680.998605] system 00:03: legacy suspend
[ 8680.998613] pnp 00:02: legacy suspend
[ 8680.998615] pnp 00:01: legacy suspend
[ 8680.998617] system 00:00: legacy suspend
[ 8680.998637] iwlagn 0000:02:00.0: suspend
[ 8680.998680] platform dock.2: suspend
[ 8680.998682] platform dock.1: suspend
[ 8680.998708] platform dock.0: suspend
[ 8680.998710] button LNXPWRBN:00: legacy suspend
[ 8680.998714] thermal LNXTHERM:01: legacy suspend
[ 8680.998717] acpi LNXTHERM:00: legacy suspend
[ 8680.998720] wmi PNP0C14:00: legacy suspend
[ 8680.998729] acpi PNP0C02:01: legacy suspend
[ 8680.998731] acpi device:32: legacy suspend
[ 8680.998733] acpi device:31: legacy suspend
[ 8680.998736] acpi device:2f: legacy suspend
[ 8680.998738] acpi device:2e: legacy suspend
[ 8680.998740] acpi device:2d: legacy suspend
[ 8680.998764] acpi device:2c: legacy suspend
[ 8680.998767] acpi device:2b: legacy suspend
[ 8680.998770] acpi device:2a: legacy suspend
[ 8680.998772] acpi device:29: legacy suspend
[ 8680.998774] acpi device:28: legacy suspend
[ 8680.998776] acpi device:27: legacy suspend
[ 8680.998778] acpi device:26: legacy suspend
[ 8680.998781] acpi device:25: legacy suspend
[ 8680.998789] acpi device:24: legacy suspend
[ 8680.998792] acpi device:23: legacy suspend
[ 8680.998794] acpi device:22: legacy suspend
[ 8680.998796] acpi device:21: legacy suspend
[ 8680.998812] acpi device:20: legacy suspend
[ 8680.998814] acpi device:1f: legacy suspend
[ 8680.998817] acpi device:1e: legacy suspend
[ 8680.998819] acpi device:1d: legacy suspend
[ 8680.998821] acpi device:1c: legacy suspend
[ 8680.998823] acpi device:1b: legacy suspend
[ 8680.998825] acpi device:1a: legacy suspend
[ 8680.998828] acpi device:19: legacy suspend
[ 8680.998836] acpi device:18: legacy suspend
[ 8680.998838] acpi device:17: legacy suspend
[ 8680.998862] acpi device:16: legacy suspend
[ 8680.998885] acpi device:15: legacy suspend
[ 8680.998888] acpi device:14: legacy suspend
[ 8680.998890] acpi device:13: legacy suspend
[ 8680.998892] pci 0000:00:1f.6: suspend
[ 8680.998894] acpi device:12: legacy suspend
[ 8680.998897] acpi device:11: legacy suspend
[ 8680.998899] i801_smbus 0000:00:1f.3: suspend
[ 8680.998901] acpi device:10: legacy suspend
[ 8680.998903] acpi device:0f: legacy suspend
[ 8680.998905] acpi device:0e: legacy suspend
[ 8680.998906] acpi device:0d: legacy suspend
[ 8680.998908] acpi device:0c: legacy suspend
[ 8680.998910] acpi device:0b: legacy suspend
[ 8680.998912] acpi LNXVIDEO:01: legacy suspend
[ 8680.998914] acpi device:0a: legacy suspend
[ 8680.998917] thinkpad_hotkey IBM0068:00: legacy suspend
[ 8680.998919] ac ACPI0003:00: legacy suspend
[ 8680.998921] battery PNP0C0A:00: legacy suspend
[ 8680.998924] power LNXPOWER:00: legacy suspend
[ 8680.998927] ec PNP0C09:00: legacy suspend
[ 8680.998934] acpi SMO1200:00: legacy suspend
[ 8680.998936] acpi LEN0018:00: legacy suspend
[ 8680.998938] acpi PNP0303:00: legacy suspend
[ 8680.998940] acpi PNP0B00:00: legacy suspend
[ 8680.998942] acpi PNP0C04:00: legacy suspend
[ 8680.998944] acpi PNP0800:00: legacy suspend
[ 8680.998945] acpi PNP0200:00: legacy suspend
[ 8680.998947] acpi PNP0103:00: legacy suspend
[ 8680.998949] acpi PNP0100:00: legacy suspend
[ 8680.998950] acpi PNP0000:00: legacy suspend
[ 8680.998952] acpi PNP0C02:00: legacy suspend
[ 8680.998954] acpi device:09: legacy suspend
[ 8680.998956] acpi device:08: legacy suspend
[ 8680.998957] acpi device:07: legacy suspend
[ 8680.998959] acpi device:06: legacy suspend
[ 8680.998961] acpi device:05: legacy suspend
[ 8680.998962] acpi device:04: legacy suspend
[ 8680.998964] acpi device:03: legacy suspend
[ 8680.998965] acpi device:02: legacy suspend
[ 8680.998967] acpi device:01: legacy suspend
[ 8680.998970] video LNXVIDEO:00: legacy suspend
[ 8680.998973] pci_root PNP0A08:00: legacy suspend
[ 8680.998975] acpi device:00: legacy suspend
[ 8680.998976] pci_root PNP0A03:00: legacy suspend
[ 8680.998978] button PNP0C0E:00: legacy suspend
[ 8680.998980] button PNP0C0D:00: legacy suspend
[ 8680.998982] acpi PNP0C01:00: legacy suspend
[ 8680.998984] pci_link PNP0C0F:07: legacy suspend
[ 8680.998986] pci_link PNP0C0F:06: legacy suspend
[ 8680.998987] pci_link PNP0C0F:05: legacy suspend
[ 8680.998989] pci_link PNP0C0F:04: legacy suspend
[ 8680.998991] pci_link PNP0C0F:03: legacy suspend
[ 8680.998993] pci_link PNP0C0F:02: legacy suspend
[ 8680.998995] pci_link PNP0C0F:01: legacy suspend
[ 8680.998998] pci 0000:00:1f.0: suspend
[ 8680.999000] pci_link PNP0C0F:00: legacy suspend
[ 8680.999002] pci 0000:00:1e.0: suspend
[ 8680.999004] acpi LNXSYBUS:00: legacy suspend
[ 8680.999006] ehci_hcd 0000:00:1d.0: suspend
[ 8680.999008] processor LNXCPU:07: legacy suspend
[ 8680.999013] processor LNXCPU:06: legacy suspend
[ 8680.999015] processor LNXCPU:05: legacy suspend
[ 8680.999017] processor LNXCPU:04: legacy suspend
[ 8680.999020] processor LNXCPU:03: legacy suspend
[ 8680.999023] processor LNXCPU:02: legacy suspend
[ 8680.999025] ehci_hcd 0000:00:1d.0: PCI INT D disabled
[ 8680.999027] processor LNXCPU:01: legacy suspend
[ 8680.999029] processor LNXCPU:00: legacy suspend
[ 8680.999033] acpi LNXSYSTM:00: legacy suspend
[ 8680.999035] pcieport 0000:00:1c.3: suspend
[ 8680.999039] pcieport 0000:00:1c.0: suspend
[ 8680.999044] HDA Intel 0000:00:1b.0: suspend
[ 8680.999056] ehci_hcd 0000:00:1a.0: suspend
[ 8680.999070] ehci_hcd 0000:00:1a.0: PCI INT D disabled
[ 8680.999074] e1000e 0000:00:19.0: suspend, may wakeup
[ 8681.008537] serial 0000:00:16.3: suspend
[ 8681.008578] ACPI handle has no context!
[ 8681.009559] pci 0000:00:16.0: suspend
[ 8681.009561] pcieport 0000:00:1c.4: suspend
[ 8681.009564] i915 0000:00:02.0: suspend
[ 8681.009566] agpgart-intel 0000:00:00.0: suspend
[ 8681.020387] pci 0000:ff:02.3: suspend
[ 8681.020390] pci 0000:ff:02.2: suspend
[ 8681.020392] pci 0000:ff:02.1: suspend
[ 8681.020394] pci 0000:ff:02.0: suspend
[ 8681.020396] pci 0000:ff:00.1: suspend
[ 8681.020399] pci 0000:ff:00.0: suspend
[ 8681.025442] i915 0000:00:02.0: power state changed by ACPI to D3
[ 8681.099761] HDA Intel 0000:00:1b.0: PCI INT B disabled
[ 8681.109823] e1000e 0000:00:19.0: PME# enabled
[ 8681.109835] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
[ 8681.173617] scsi target0:0:0: legacy suspend
[ 8681.173622] scsi host0: legacy suspend
[ 8681.173629] ahci 0000:00:1f.2: suspend
[ 8681.238980] PM: suspend of devices complete after 704.542 msecs
[ 8681.239017] input input9: LATE type suspend
[ 8681.239020] i2c i2c-4: LATE suspend
[ 8681.239022] i2c i2c-3: LATE suspend
[ 8681.239024] i2c i2c-2: LATE suspend
[ 8681.239026] i2c i2c-1: LATE suspend
[ 8681.239032] input input8: LATE type suspend
[ 8681.239034] input input7: LATE type suspend
[ 8681.239037] usb 1-1.6: LATE type suspend
[ 8681.239040] usb 1-1.3: LATE type suspend
[ 8681.239042] usb 2-1: LATE type suspend
[ 8681.239044] usb 1-1: LATE type suspend
[ 8681.239046] input input6: LATE type suspend
[ 8681.239049] thinkpad_hwmon thinkpad_hwmon: LATE suspend
[ 8681.239052] thinkpad_acpi thinkpad_acpi: LATE suspend
[ 8681.239055] usb usb2: LATE type suspend, may wakeup
[ 8681.239057] usb usb1: LATE type suspend, may wakeup
[ 8681.239060] i2c i2c-0: LATE suspend
[ 8681.239062] serial8250 serial8250: LATE suspend
[ 8681.239064] platform regulatory.0: LATE suspend
[ 8681.239067] input input5: LATE type suspend
[ 8681.239069] psmouse serio2: LATE suspend
[ 8681.239071] input input4: LATE type suspend
[ 8681.239074] input input3: LATE type suspend
[ 8681.239076] psmouse serio1: LATE suspend
[ 8681.239078] atkbd serio0: LATE suspend
[ 8681.239080] i8042 i8042: LATE suspend
[ 8681.239098] input input2: LATE type suspend
[ 8681.239100] input input1: LATE type suspend
[ 8681.239103] input input0: LATE type suspend
[ 8681.239105] platform microcode: LATE suspend
[ 8681.239107] pcspkr pcspkr: LATE suspend
[ 8681.239110] iwlagn 0000:02:00.0: LATE suspend
[ 8681.239113] pci 0000:00:1f.6: LATE suspend
[ 8681.239147] i801_smbus 0000:00:1f.3: LATE suspend
[ 8681.239149] ahci 0000:00:1f.2: LATE suspend
[ 8681.239151] pci 0000:00:1f.0: LATE suspend
[ 8681.239181] pci 0000:00:1e.0: LATE suspend
[ 8681.239210] ehci_hcd 0000:00:1d.0: LATE suspend
[ 8681.252014] ehci_hcd 0000:00:1d.0: power state changed by ACPI to D3
[ 8681.252019] pcieport 0000:00:1c.4: LATE suspend
[ 8681.252069] pcieport 0000:00:1c.3: LATE suspend
[ 8681.252118] pcieport 0000:00:1c.0: LATE suspend
[ 8681.252168] HDA Intel 0000:00:1b.0: LATE suspend
[ 8681.252170] ehci_hcd 0000:00:1a.0: LATE suspend
[ 8681.269959] ehci_hcd 0000:00:1a.0: power state changed by ACPI to D3
[ 8681.269964] e1000e 0000:00:19.0: LATE suspend, may wakeup
[ 8681.269966] serial 0000:00:16.3: LATE suspend
[ 8681.269969] pci 0000:00:16.0: LATE suspend
[ 8681.270004] i915 0000:00:02.0: LATE suspend
[ 8681.270006] agpgart-intel 0000:00:00.0: LATE suspend
[ 8681.270018] pci 0000:ff:02.3: LATE suspend
[ 8681.270026] pci 0000:ff:02.2: LATE suspend
[ 8681.270034] pci 0000:ff:02.1: LATE suspend
[ 8681.270043] pci 0000:ff:02.0: LATE suspend
[ 8681.270051] pci 0000:ff:00.1: LATE suspend
[ 8681.270059] pci 0000:ff:00.0: LATE suspend
[ 8681.270068] platform dock.2: LATE suspend
[ 8681.270070] platform dock.1: LATE suspend
[ 8681.270072] platform dock.0: LATE suspend
[ 8681.270078] PM: late suspend of devices complete after 31.154 msecs
[ 8681.279943] ACPI: Preparing to enter system sleep state S3
[ 8681.317911] PM: Saving platform NVS memory
[ 8681.450645] Disabling non-boot CPUs ...
[ 8681.463763] CPU 1 is now offline
[ 8681.479711] CPU 2 is now offline
[ 8681.596325] CPU 3 is now offline
[ 8681.596327] SMP alternatives: switching to UP code
[ 8681.599986] Extended CMOS year: 2000
[18446744058.743046] Back to C!
[18446744058.743049] PM: Restoring platform NVS memory
[18446744058.880452] Extended CMOS year: 2000
[18446744058.880470] Enabling non-boot CPUs ...
[18446744058.880820] SMP alternatives: switching to SMP code
[18446744058.883811] Booting Node 0 Processor 1 APIC 0x1
[18446744058.983725] CPU1 is up
[18446744058.983858] Booting Node 0 Processor 2 APIC 0x4
[18446744059.090643] CPU2 is up
[18446744059.090773] Booting Node 0 Processor 3 APIC 0x5
[18446744059.197444] CPU3 is up
[18446744059.198921] ACPI: Waking up from system sleep state S3
[18446744059.275240] platform dock.0: EARLY resume
[18446744059.275244] platform dock.1: EARLY resume
[18446744059.275246] platform dock.2: EARLY resume
[18446744059.275249] pci 0000:ff:00.0: EARLY resume
[18446744059.275263] pci 0000:ff:00.1: EARLY resume
[18446744059.275273] pci 0000:ff:02.0: EARLY resume
[18446744059.275283] pci 0000:ff:02.1: EARLY resume
[18446744059.275292] pci 0000:ff:02.2: EARLY resume
[18446744059.275302] pci 0000:ff:02.3: EARLY resume
[18446744059.275312] agpgart-intel 0000:00:00.0: EARLY resume
[18446744059.275327] i915 0000:00:02.0: EARLY resume
[18446744059.275341] i915 0000:00:02.0: restoring config space at offset 0x=
1 (was 0x900007, writing 0x900407)
[18446744059.275355] pci 0000:00:16.0: EARLY resume
[18446744059.275399] serial 0000:00:16.3: EARLY resume
[18446744059.275443] e1000e 0000:00:19.0: EARLY resume
[18446744059.275492] ehci_hcd 0000:00:1a.0: EARLY resume
[18446744059.275510] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.275530] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728000)
[18446744059.275540] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.286150] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.288159] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.288165] HDA Intel 0000:00:1b.0: EARLY resume
[18446744059.288217] pcieport 0000:00:1c.0: EARLY resume
[18446744059.288257] pcieport 0000:00:1c.0: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.288290] pcieport 0000:00:1c.3: EARLY resume
[18446744059.288332] pcieport 0000:00:1c.3: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.288365] pcieport 0000:00:1c.4: EARLY resume
[18446744059.288387] pcieport 0000:00:1c.4: restoring config space at offse=
t 0xf (was 0x100, writing 0x4010b)
[18446744059.288400] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x9 (was 0x10001, writing 0x1fff1)
[18446744059.288407] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x8 (was 0x0, writing 0xf240f240)
[18446744059.288414] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x7 (was 0x0, writing 0xf0)
[18446744059.288425] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x3 (was 0x810000, writing 0x810010)
[18446744059.288433] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x1 (was 0x100000, writing 0x100507)
[18446744059.288466] ehci_hcd 0000:00:1d.0: EARLY resume
[18446744059.288483] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.288503] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728400)
[18446744059.288513] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.290156] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.292151] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.292157] pci 0000:00:1e.0: EARLY resume
[18446744059.292193] pci 0000:00:1f.0: EARLY resume
[18446744059.292231] ahci 0000:00:1f.2: EARLY resume
[18446744059.292269] ahci 0000:00:1f.2: restoring config space at offset 0x=
1 (was 0x2b00007, writing 0x2b00407)
[18446744059.292302] i801_smbus 0000:00:1f.3: EARLY resume
[18446744059.292331] pci 0000:00:1f.6: EARLY resume
[18446744059.292346] pci 0000:00:1f.6: restoring config space at offset 0xf=
 (was 0x400, writing 0x40b)
[18446744059.292370] pci 0000:00:1f.6: restoring config space at offset 0x1=
 (was 0x100000, writing 0x100002)
[18446744059.292386] iwlagn 0000:02:00.0: EARLY resume
[18446744059.292459] iwlagn 0000:02:00.0: restoring config space at offset =
0x1 (was 0x100106, writing 0x100506)
[18446744059.292519] pcspkr pcspkr: EARLY resume
[18446744059.292522] platform microcode: EARLY resume
[18446744059.292526] input input0: EARLY type resume
[18446744059.292528] input input1: EARLY type resume
[18446744059.292531] input input2: EARLY type resume
[18446744059.292580] i8042 i8042: EARLY resume
[18446744059.292583] atkbd serio0: EARLY resume
[18446744059.292585] psmouse serio1: EARLY resume
[18446744059.292588] input input3: EARLY type resume
[18446744059.292592] input input4: EARLY type resume
[18446744059.292595] psmouse serio2: EARLY resume
[18446744059.292598] input input5: EARLY type resume
[18446744059.292601] platform regulatory.0: EARLY resume
[18446744059.292603] serial8250 serial8250: EARLY resume
[18446744059.292607] i2c i2c-0: EARLY resume
[18446744059.292610] usb usb1: EARLY type resume
[18446744059.292613] usb usb2: EARLY type resume
[18446744059.292618] thinkpad_acpi thinkpad_acpi: EARLY resume
[18446744059.292621] thinkpad_hwmon thinkpad_hwmon: EARLY resume
[18446744059.292626] input input6: EARLY type resume
[18446744059.292629] usb 1-1: EARLY type resume
[18446744059.292632] usb 2-1: EARLY type resume
[18446744059.292635] usb 1-1.3: EARLY type resume
[18446744059.292638] usb 1-1.6: EARLY type resume
[18446744059.292641] input input7: EARLY type resume
[18446744059.292644] input input8: EARLY type resume
[18446744059.292660] i2c i2c-1: EARLY resume
[18446744059.292662] i2c i2c-2: EARLY resume
[18446744059.292665] i2c i2c-3: EARLY resume
[18446744059.292667] i2c i2c-4: EARLY resume
[18446744059.292670] input input9: EARLY type resume
[18446744059.292673] PM: early resume of devices complete after 17.478 msecs
[18446744059.292750] pci 0000:ff:00.0: resume
[18446744059.292763] pci 0000:ff:00.1: resume
[18446744059.292809] pci 0000:ff:02.0: resume
[18446744059.292836] pci 0000:ff:02.1: resume
[18446744059.292865] pci 0000:ff:02.2: resume
[18446744059.292892] pci 0000:ff:02.3: resume
[18446744059.292949] agpgart-intel 0000:00:00.0: resume
[18446744059.292985] i915 0000:00:02.0: resume
[18446744059.293051] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.293112] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.293116] i915 0000:00:02.0: setting latency timer to 64
[18446744059.293360] pci 0000:00:16.0: resume
[18446744059.293384] serial 0000:00:16.3: resume
[18446744059.293413] e1000e 0000:00:19.0: resume
[18446744059.293428] e1000e 0000:00:19.0: wake-up capability disabled by AC=
PI
[18446744059.293435] e1000e 0000:00:19.0: PME# disabled
[18446744059.293509] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[18446744059.299804] ehci_hcd 0000:00:1a.0: resume
[18446744059.299845] HDA Intel 0000:00:1b.0: resume
[18446744059.299860] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, lo=
w) -> IRQ 17
[18446744059.299867] HDA Intel 0000:00:1b.0: setting latency timer to 64
[18446744059.299933] HDA Intel 0000:00:1b.0: irq 45 for MSI/MSI-X
[18446744059.300016] pcieport 0000:00:1c.0: resume
[18446744059.300054] pcieport 0000:00:1c.3: resume
[18446744059.300059] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.300094] pcieport 0000:00:1c.4: resume
[18446744059.300131] ehci_hcd 0000:00:1d.0: resume
[18446744059.300196] pci 0000:00:1e.0: resume
[18446744059.300206] pci 0000:00:1e.0: setting latency timer to 64
[18446744059.300251] pci 0000:00:1f.0: resume
[18446744059.300282] ahci 0000:00:1f.2: resume
[18446744059.300317] i801_smbus 0000:00:1f.3: resume
[18446744059.300347] pci 0000:00:1f.6: resume
[18446744059.300378] ahci 0000:00:1f.2: setting latency timer to 64
[18446744059.300416] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.300424] ehci_hcd 0000:00:1a.0: PCI INT D -> GSI 23 (level, low=
) -> IRQ 23
[18446744059.300431] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[18446744059.300477] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.300516] iwlagn 0000:02:00.0: resume
[18446744059.300577] scsi host0: legacy resume
[18446744059.300691] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.300703] ehci_hcd 0000:00:1d.0: PCI INT D -> GSI 19 (level, low=
) -> IRQ 19
[18446744059.300709] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[18446744059.300756] scsi host1: legacy resume
[18446744059.300817] scsi host2: legacy resume
[18446744059.300878] scsi host3: legacy resume
[18446744059.300934] scsi host4: legacy resume
[18446744059.300997] scsi host5: legacy resume
[18446744059.301053] scsi target0:0:0: legacy resume
[18446744059.301098] sd 0:0:0:0: legacy resume
[18446744059.301101] sd 0:0:0:0: [sda] Starting disk
[18446744059.301182] usb usb1: type resume
[18446744059.301240] usb usb2: type resume
[18446744059.301534] acpi LNXSYSTM:00: legacy resume
[18446744059.301537] processor LNXCPU:00: legacy resume
[18446744059.301540] processor LNXCPU:01: legacy resume
[18446744059.301542] processor LNXCPU:02: legacy resume
[18446744059.301544] processor LNXCPU:03: legacy resume
[18446744059.301546] processor LNXCPU:04: legacy resume
[18446744059.301547] processor LNXCPU:05: legacy resume
[18446744059.301549] processor LNXCPU:06: legacy resume
[18446744059.301551] processor LNXCPU:07: legacy resume
[18446744059.301553] acpi LNXSYBUS:00: legacy resume
[18446744059.301555] pci_link PNP0C0F:00: legacy resume
[18446744059.301557] pci_link PNP0C0F:01: legacy resume
[18446744059.301559] pci_link PNP0C0F:02: legacy resume
[18446744059.301561] pci_link PNP0C0F:03: legacy resume
[18446744059.301563] pci_link PNP0C0F:04: legacy resume
[18446744059.301565] pci_link PNP0C0F:05: legacy resume
[18446744059.301567] pci_link PNP0C0F:06: legacy resume
[18446744059.301569] pci_link PNP0C0F:07: legacy resume
[18446744059.301570] acpi PNP0C01:00: legacy resume
[18446744059.301573] button PNP0C0D:00: legacy resume
[18446744059.301970] button PNP0C0E:00: legacy resume
[18446744059.301972] pci_root PNP0A03:00: legacy resume
[18446744059.301974] acpi device:00: legacy resume
[18446744059.301976] pci_root PNP0A08:00: legacy resume
[18446744059.301979] video LNXVIDEO:00: legacy resume
[18446744059.301981] acpi device:01: legacy resume
[18446744059.301983] acpi device:02: legacy resume
[18446744059.301985] acpi device:03: legacy resume
[18446744059.301987] acpi device:04: legacy resume
[18446744059.301989] acpi device:05: legacy resume
[18446744059.301991] acpi device:06: legacy resume
[18446744059.301992] acpi device:07: legacy resume
[18446744059.301995] acpi device:08: legacy resume
[18446744059.301996] acpi device:09: legacy resume
[18446744059.301998] acpi PNP0C02:00: legacy resume
[18446744059.302000] acpi PNP0000:00: legacy resume
[18446744059.302002] acpi PNP0100:00: legacy resume
[18446744059.302004] acpi PNP0103:00: legacy resume
[18446744059.302006] acpi PNP0200:00: legacy resume
[18446744059.302008] acpi PNP0800:00: legacy resume
[18446744059.302010] acpi PNP0C04:00: legacy resume
[18446744059.302011] acpi PNP0B00:00: legacy resume
[18446744059.302013] acpi PNP0303:00: legacy resume
[18446744059.302015] acpi LEN0018:00: legacy resume
[18446744059.302017] acpi SMO1200:00: legacy resume
[18446744059.302019] ec PNP0C09:00: legacy resume
[18446744059.302025] power LNXPOWER:00: legacy resume
[18446744059.302235] battery PNP0C0A:00: legacy resume
[18446744059.318677] ac ACPI0003:00: legacy resume
[18446744059.318904] thinkpad_hotkey IBM0068:00: legacy resume
[18446744059.318906] acpi device:0a: legacy resume
[18446744059.318908] acpi LNXVIDEO:01: legacy resume
[18446744059.318911] acpi device:0b: legacy resume
[18446744059.318913] acpi device:0c: legacy resume
[18446744059.318914] acpi device:0d: legacy resume
[18446744059.318916] acpi device:0e: legacy resume
[18446744059.318918] acpi device:0f: legacy resume
[18446744059.318920] acpi device:10: legacy resume
[18446744059.318921] acpi device:11: legacy resume
[18446744059.318923] acpi device:12: legacy resume
[18446744059.318925] acpi device:13: legacy resume
[18446744059.318927] acpi device:14: legacy resume
[18446744059.318929] acpi device:15: legacy resume
[18446744059.318931] acpi device:16: legacy resume
[18446744059.318933] acpi device:17: legacy resume
[18446744059.318935] acpi device:18: legacy resume
[18446744059.318937] acpi device:19: legacy resume
[18446744059.318938] acpi device:1a: legacy resume
[18446744059.318940] acpi device:1b: legacy resume
[18446744059.318942] acpi device:1c: legacy resume
[18446744059.318944] acpi device:1d: legacy resume
[18446744059.318946] acpi device:1e: legacy resume
[18446744059.318948] acpi device:1f: legacy resume
[18446744059.318950] acpi device:20: legacy resume
[18446744059.318952] acpi device:21: legacy resume
[18446744059.318954] acpi device:22: legacy resume
[18446744059.318956] acpi device:23: legacy resume
[18446744059.318958] acpi device:24: legacy resume
[18446744059.318959] acpi device:25: legacy resume
[18446744059.318961] acpi device:26: legacy resume
[18446744059.318963] acpi device:27: legacy resume
[18446744059.318965] acpi device:28: legacy resume
[18446744059.318966] acpi device:29: legacy resume
[18446744059.318968] acpi device:2a: legacy resume
[18446744059.318970] acpi device:2b: legacy resume
[18446744059.318972] acpi device:2c: legacy resume
[18446744059.318973] acpi device:2d: legacy resume
[18446744059.318975] acpi device:2e: legacy resume
[18446744059.318977] acpi device:2f: legacy resume
[18446744059.318979] acpi device:31: legacy resume
[18446744059.318980] acpi device:32: legacy resume
[18446744059.318982] acpi PNP0C02:01: legacy resume
[18446744059.318984] wmi PNP0C14:00: legacy resume
[18446744059.318986] acpi LNXTHERM:00: legacy resume
[18446744059.318988] thermal LNXTHERM:01: legacy resume
[18446744059.319686] button LNXPWRBN:00: legacy resume
[18446744059.319688] platform dock.0: resume
[18446744059.319690] platform dock.1: resume
[18446744059.319692] platform dock.2: resume
[18446744059.319698] system 00:00: legacy resume
[18446744059.319704] pnp 00:01: legacy resume
[18446744059.319706] pnp 00:02: legacy resume
[18446744059.319708] system 00:03: legacy resume
[18446744059.319710] pnp 00:04: legacy resume
[18446744059.319712] pnp 00:05: legacy resume
[18446744059.319714] pnp 00:06: legacy resume
[18446744059.319716] pnp 00:07: legacy resume
[18446744059.319718] rtc_cmos 00:08: legacy resume
[18446744059.319722] i8042 kbd 00:09: legacy resume
[18446744059.319725] i8042 aux 00:0a: legacy resume
[18446744059.319727] tpm_tis 00:0b: legacy resume
[18446744059.319731] system 00:0c: legacy resume
[18446744059.319736] pcspkr pcspkr: resume
[18446744059.319738] platform microcode: resume
[18446744059.319742] input input0: type resume
[18446744059.319744] input input1: type resume
[18446744059.319745] input input2: type resume
[18446744059.319851] i8042 i8042: resume
[18446744059.320696] atkbd serio0: resume
[18446744059.320769] psmouse serio1: resume
[18446744059.320772] input input3: type resume
[18446744059.346037] usb 2-1: type resume
[18446744059.346057] usb 1-1: type resume
[18446744059.447770] usb 1-1.3: type resume
[18446744059.447799] usb 1-1.6: type resume
[18446744059.520789] usb 1-1.3: reset full speed USB device using ehci_hcd =
and address 3
[18446744059.606511] ata2: SATA link down (SStatus 0 SControl 300)
[18446744059.608600] ata5: SATA link down (SStatus 0 SControl 300)
[18446744059.610529] ata6: SATA link down (SStatus 0 SControl 300)
[18446744059.678367] usb 1-1.6: reset high speed USB device using ehci_hcd =
and address 6
[18446744061.844262] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[18446744061.846717] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.846723] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.846728] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.851507] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.851513] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.851518] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.853705] ata1.00: configured for UDMA/100
[18446744061.868680] ata1.00: configured for UDMA/100
[18446744061.868685] ata1: EH complete
[18446744061.890716] input input4: type resume
[18446744061.890722] psmouse serio2: resume
[18446744061.890729] input input5: type resume
[18446744061.890755] platform regulatory.0: resume
[18446744061.890758] serial8250 serial8250: resume
[18446744061.890765] i2c i2c-0: resume
[18446744061.890783] thinkpad_acpi thinkpad_acpi: resume
[18446744061.893944] thinkpad_hwmon thinkpad_hwmon: resume
[18446744061.893948] rfkill rfkill0: legacy class resume
[18446744061.893950] leds tpacpi::thinklight: legacy class resume
[18446744061.893953] leds tpacpi::power: legacy class resume
[18446744061.893955] leds tpacpi:orange:batt: legacy class resume
[18446744061.893957] leds tpacpi:green:batt: legacy class resume
[18446744061.893959] leds tpacpi::dock_active: legacy class resume
[18446744061.893961] leds tpacpi::bay_active: legacy class resume
[18446744061.893963] leds tpacpi::dock_batt: legacy class resume
[18446744061.893965] leds tpacpi::unknown_led: legacy class resume
[18446744061.893968] leds tpacpi::standby: legacy class resume
[18446744061.893970] leds tpacpi::dock_status1: legacy class resume
[18446744061.893972] leds tpacpi::dock_status2: legacy class resume
[18446744061.893974] leds tpacpi::unknown_led2: legacy class resume
[18446744061.893975] leds tpacpi::unknown_led3: legacy class resume
[18446744061.893977] leds tpacpi::thinkvantage: legacy class resume
[18446744061.893980] input input6: type resume
[18446744061.893986] ieee80211 phy0: legacy class resume
[18446744061.994828] rfkill rfkill1: legacy class resume
[18446744061.994859] input input7: type resume
[18446744061.994864] input input8: type resume
[18446744061.994907] drm controlD64: legacy class resume
[18446744061.994910] drm card0: legacy class resume
[18446744061.994912] i2c i2c-1: resume
[18446744061.994914] drm card0-VGA-1: legacy class resume
[18446744061.994915] i2c i2c-2: resume
[18446744061.994917] drm card0-LVDS-1: legacy class resume
[18446744061.994919] i2c i2c-3: resume
[18446744061.994921] drm card0-HDMI Type A-1: legacy class resume
[18446744061.994923] drm card0-DisplayPort-1: legacy class resume
[18446744061.994924] i2c i2c-4: resume
[18446744061.994927] backlight acpi_video0: legacy class resume
[18446744061.994932] input input9: type resume
[18446744061.994937] PM: resume of devices complete after 2707.386 msecs
[18446744061.994954] usb 1-1.6: completing type resume
[18446744061.994956] usb 1-1.3: completing type resume
[18446744061.994959] usb 2-1: completing type resume
[18446744061.994961] usb 1-1: completing type resume
[18446744061.994965] thinkpad_hwmon thinkpad_hwmon: completing resume
[18446744061.994967] thinkpad_acpi thinkpad_acpi: completing resume
[18446744061.994971] usb usb2: completing type resume
[18446744061.994973] usb usb1: completing type resume
[18446744061.994976] serial8250 serial8250: completing resume
[18446744061.994978] platform regulatory.0: completing resume
[18446744061.994984] i8042 i8042: completing resume
[18446744061.995072] platform microcode: completing resume
[18446744061.995074] pcspkr pcspkr: completing resume
[18446744061.995081] iwlagn 0000:02:00.0: completing resume
[18446744061.995083] pci 0000:00:1f.6: completing resume
[18446744061.995085] i801_smbus 0000:00:1f.3: completing resume
[18446744061.995087] ahci 0000:00:1f.2: completing resume
[18446744061.995089] pci 0000:00:1f.0: completing resume
[18446744061.995091] pci 0000:00:1e.0: completing resume
[18446744061.995092] ehci_hcd 0000:00:1d.0: completing resume
[18446744061.995095] pcieport 0000:00:1c.4: completing resume
[18446744061.995097] pcieport 0000:00:1c.3: completing resume
[18446744061.995099] pcieport 0000:00:1c.0: completing resume
[18446744061.995101] HDA Intel 0000:00:1b.0: completing resume
[18446744061.995103] ehci_hcd 0000:00:1a.0: completing resume
[18446744061.995105] e1000e 0000:00:19.0: completing resume
[18446744061.995107] serial 0000:00:16.3: completing resume
[18446744061.995109] pci 0000:00:16.0: completing resume
[18446744061.995111] i915 0000:00:02.0: completing resume
[18446744061.995113] agpgart-intel 0000:00:00.0: completing resume
[18446744061.995116] pci 0000:ff:02.3: completing resume
[18446744061.995117] pci 0000:ff:02.2: completing resume
[18446744061.995119] pci 0000:ff:02.1: completing resume
[18446744061.995121] pci 0000:ff:02.0: completing resume
[18446744061.995122] pci 0000:ff:00.1: completing resume
[18446744061.995124] pci 0000:ff:00.0: completing resume
[18446744061.995126] platform dock.2: completing resume
[18446744061.995128] platform dock.1: completing resume
[18446744061.995130] platform dock.0: completing resume
[18446744061.995231] PM: Finishing wakeup.
[18446744061.995233] Restarting tasks ...=20
[18446744062.004996] PM: Removing info for No Bus:pan0
[18446744062.013774] done.
[18446744062.013781] video LNXVIDEO:00: Restoring backlight state
[18446744062.548888] usb 1-1.4: new full speed USB device using ehci_hcd an=
d address 10
[18446744062.638546] PM: Adding info for usb:1-1.4
[18446744062.638848] PM: Adding info for usb:1-1.4:1.0
[18446744062.638977] PM: Adding info for No Bus:hci0
[18446744062.639036] PM: Adding info for No Bus:rfkill5
[18446744062.639094] PM: Adding info for No Bus:ep_81
[18446744062.639118] PM: Adding info for No Bus:ep_82
[18446744062.639140] PM: Adding info for No Bus:ep_02
[18446744062.639166] PM: Adding info for usb:1-1.4:1.1
[18446744062.639215] PM: Adding info for No Bus:ep_83
[18446744062.639238] PM: Adding info for No Bus:ep_03
[18446744062.639266] PM: Adding info for usb:1-1.4:1.2
[18446744062.639346] PM: Adding info for No Bus:ep_84
[18446744062.639369] PM: Adding info for No Bus:ep_04
[18446744062.639397] PM: Adding info for usb:1-1.4:1.3
[18446744062.639457] PM: Adding info for No Bus:ep_00
[18446744062.660688] PM: Adding info for No Bus:pan0
[18446744066.499215] thinkpad_acpi: EC reports that Thermal Table has chang=
ed
[18446744066.794298] ata2: exception Emask 0x10 SAct 0x0 SErr 0x4040000 act=
ion 0xe frozen
[18446744066.794303] ata2: irq_stat 0x000000c0, connection status changed
[18446744066.794309] ata2: SError: { CommWake DevExch }
[18446744066.794322] ata2: hard resetting link
[18446744067.066858] ACPI: \_SB_.GDCK - docking
[18446744067.069473] PM: Adding info for acpi:LNXIOBAY:01
[18446744067.069544] PM: Adding info for acpi:device:33
[18446744067.070327] PM: Adding info for acpi:IBM0079:01
[18446744067.657132] usb 1-1.5: new high speed USB device using ehci_hcd an=
d address 11
[18446744067.719021] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[18446744067.724558] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[18446744067.725552] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[18446744067.729447] ata2.00: ATAPI: HL-DT-ST DVDRAM GSA-U20N, HX10, max UD=
MA/133
[18446744067.736333] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[18446744067.737226] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[18446744067.741161] ata2.00: configured for UDMA/133
[18446744067.742306] PM: Adding info for usb:1-1.5
[18446744067.742462] PM: Adding info for usb:1-1.5:1.0
[18446744067.742498] hub 1-1.5:1.0: USB hub found
[18446744067.742580] hub 1-1.5:1.0: 4 ports detected
[18446744067.742709] PM: Adding info for No Bus:ep_81
[18446744067.743472] PM: Adding info for No Bus:ep_00
[18446744067.855275] ata2: EH complete
[18446744067.858758] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVDRAM GSA-U2=
0N  HX10 PQ: 0 ANSI: 5
[18446744067.858783] PM: Adding info for scsi:target1:0:0
[18446744067.858834] PM: Adding info for scsi:1:0:0:0
[18446744068.187794] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/=
form2 cdda tray
[18446744068.187839] PM: Adding info for No Bus:sr0
[18446744068.187925] PM: Adding info for No Bus:11:0
[18446744068.187950] sr 1:0:0:0: Attached scsi CD-ROM sr0
[18446744068.187971] PM: Adding info for No Bus:1:0:0:0
[18446744068.188110] PM: Adding info for No Bus:sg1
[18446744068.188133] sr 1:0:0:0: Attached scsi generic sg1 type 5
[18446744068.188185] PM: Adding info for No Bus:1:0:0:0
[    1.365415] usb 1-1.5.2: new high speed USB device using ehci_hcd and ad=
dress 12
[    1.453462] PM: Adding info for usb:1-1.5.2
[    1.453976] PM: Adding info for usb:1-1.5.2:1.0
[    1.454346] scsi7 : usb-storage 1-1.5.2:1.0
[    1.454365] PM: Adding info for scsi:host7
[    1.454414] PM: Adding info for No Bus:host7
[    1.454584] PM: Adding info for No Bus:ep_81
[    1.454611] PM: Adding info for No Bus:ep_02
[    1.454637] PM: Adding info for No Bus:ep_00
[    2.453815] scsi 7:0:0:0: Direct-Access     WD       5000BEV External 1.=
75 PQ: 0 ANSI: 4
[    2.453846] PM: Adding info for scsi:target7:0:0
[    2.453899] PM: Adding info for scsi:7:0:0:0
[    2.453952] PM: Adding info for No Bus:7:0:0:0
[    2.453992] PM: Adding info for No Bus:7:0:0:0
[    2.454135] PM: Adding info for No Bus:sg2
[    2.454165] sd 7:0:0:0: Attached scsi generic sg2 type 0
[    2.454225] PM: Adding info for No Bus:7:0:0:0
[    2.454779] sd 7:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB=
/465 GiB)
[    2.455372] sd 7:0:0:0: [sdb] Write Protect is off
[    2.455377] sd 7:0:0:0: [sdb] Mode Sense: 23 00 00 00
[    2.455381] sd 7:0:0:0: [sdb] Assuming drive cache: write through
[    2.455429] PM: Adding info for No Bus:sdb
[    2.456617] sd 7:0:0:0: [sdb] Assuming drive cache: write through
[    2.456626]  sdb: sdb1
[    2.466702] PM: Adding info for No Bus:sdb1
[    2.466821] PM: Adding info for No Bus:8:16
[    2.468784] sd 7:0:0:0: [sdb] Assuming drive cache: write through
[    2.468790] sd 7:0:0:0: [sdb] Attached SCSI disk
[    4.065240] wlan0: deauthenticating from 00:05:4e:4d:82:6d by local choi=
ce (reason=3D3)
[    4.117030] cfg80211: Calling CRDA to update world regulatory domain
[   12.228826] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[   12.279610] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[   12.280200] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   18.282340] e1000e 0000:00:19.0: eth0: Error reading PHY register
[   18.282346] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Cont=
rol: RX
[   18.511662] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   18.642168] e1000e 0000:00:19.0: eth0: Error reading PHY register
[   18.642173] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Cont=
rol: RX
[   28.656293] eth0: no IPv6 routers present
[   50.370851] device eth0 entered promiscuous mode
[   56.515697] ata2.00: disabled
[   56.515719] ata2.00: detaching (SCSI 1:0:0:0)
[   56.515731] PM: Removing info for No Bus:1:0:0:0
[   56.515846] PM: Removing info for No Bus:1:0:0:0
[   56.515861] PM: Removing info for No Bus:sg1
[   56.515930] PM: Removing info for scsi:1:0:0:0
[   56.516003] PM: Removing info for acpi:LNXIOBAY:01
[   56.516050] PM: Removing info for acpi:device:33
[   56.516113] PM: Removing info for acpi:IBM0079:01
[   56.516145] ACPI: \_SB_.GDCK - undocking
[   56.519502] ata2: exception Emask 0x10 SAct 0x0 SErr 0x4090000 action 0x=
e frozen
[   56.519505] ata2: irq_stat 0x004000c0, connection status changed
[   56.519509] ata2: SError: { PHYRdyChg 10B8B DevExch }
[   56.519557] ata2: hard resetting link
[   56.523085] PM: Removing info for No Bus:11:0
[   56.523135] PM: Removing info for No Bus:sr0
[   56.639162] usb 1-1.5: USB disconnect, address 11
[   56.639167] usb 1-1.5.2: USB disconnect, address 12
[   56.639177] PM: Removing info for No Bus:ep_81
[   56.639195] PM: Removing info for No Bus:ep_02
[   56.639207] PM: Removing info for usb:1-1.5.2:1.0
[   56.639231] PM: Removing info for No Bus:7:0:0:0
[   56.639342] PM: Removing info for No Bus:7:0:0:0
[   56.639357] PM: Removing info for No Bus:sg2
[   56.639429] PM: Removing info for scsi:7:0:0:0
[   56.639451] PM: Removing info for No Bus:7:0:0:0
[   56.639490] PM: Removing info for No Bus:sdb1
[   56.646949] PM: Removing info for No Bus:8:16
[   56.647020] PM: Removing info for No Bus:sdb
[   56.647116] PM: Removing info for scsi:target7:0:0
[   56.647147] PM: Removing info for No Bus:host7
[   56.647186] PM: Removing info for scsi:host7
[   56.648244] PM: Removing info for No Bus:ep_00
[   56.648267] PM: Removing info for usb:1-1.5.2
[   56.648476] PM: Removing info for No Bus:ep_81
[   56.648497] PM: Removing info for usb:1-1.5:1.0
[   56.648550] PM: Removing info for No Bus:ep_00
[   56.648568] PM: Removing info for usb:1-1.5
[   57.240769] ata2: SATA link down (SStatus 0 SControl 300)
[   57.240787] ata2: EH complete
[   57.240948] PM: Removing info for scsi:target1:0:0
[   58.598211] ACPI: \_SB_.GDCK - undocking
[   59.221884] thinkpad_acpi: EC reports that Thermal Table has changed
[   59.969839] device eth0 left promiscuous mode
[   62.028734] thinkpad_acpi: EC reports that Thermal Table has changed
[   62.345521] ata2: exception Emask 0x10 SAct 0x0 SErr 0x4040000 action 0x=
e frozen
[   62.345526] ata2: irq_stat 0x000000c0, connection status changed
[   62.345531] ata2: SError: { CommWake DevExch }
[   62.345541] ata2: hard resetting link
[   62.617185] ACPI: \_SB_.GDCK - docking
[   62.621494] PM: Adding info for acpi:LNXIOBAY:02
[   62.621655] PM: Adding info for acpi:device:34
[   62.624024] PM: Adding info for acpi:IBM0079:02
[   63.204460] usb 1-1.5: new high speed USB device using ehci_hcd and addr=
ess 13
[   63.270301] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[   63.275898] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[   63.276793] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[   63.280774] ata2.00: ATAPI: HL-DT-ST DVDRAM GSA-U20N, HX10, max UDMA/133
[   63.287485] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[   63.288334] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[   63.289634] PM: Adding info for usb:1-1.5
[   63.289792] PM: Adding info for usb:1-1.5:1.0
[   63.289827] hub 1-1.5:1.0: USB hub found
[   63.289915] hub 1-1.5:1.0: 4 ports detected
[   63.290037] PM: Adding info for No Bus:ep_81
[   63.290794] PM: Adding info for No Bus:ep_00
[   63.292293] ata2.00: configured for UDMA/133
[   63.406407] ata2: EH complete
[   63.409820] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVDRAM GSA-U20N  HX=
10 PQ: 0 ANSI: 5
[   63.409849] PM: Adding info for scsi:target1:0:0
[   63.409903] PM: Adding info for scsi:1:0:0:0
[   63.738942] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 =
cdda tray
[   63.738989] PM: Adding info for No Bus:sr0
[   63.739074] PM: Adding info for No Bus:11:0
[   63.739099] sr 1:0:0:0: Attached scsi CD-ROM sr0
[   63.739121] PM: Adding info for No Bus:1:0:0:0
[   63.739246] PM: Adding info for No Bus:sg1
[   63.739269] sr 1:0:0:0: Attached scsi generic sg1 type 5
[   63.739345] PM: Adding info for No Bus:1:0:0:0
[   69.431462] device eth0 entered promiscuous mode
[   70.622282] usb 1-1.5.2: new high speed USB device using ehci_hcd and ad=
dress 14
[   70.709551] PM: Adding info for usb:1-1.5.2
[   70.709749] PM: Adding info for usb:1-1.5.2:1.0
[   70.709989] scsi8 : usb-storage 1-1.5.2:1.0
[   70.710008] PM: Adding info for scsi:host8
[   70.710095] PM: Adding info for No Bus:host8
[   70.710194] PM: Adding info for No Bus:ep_81
[   70.710208] PM: Adding info for No Bus:ep_02
[   70.710224] PM: Adding info for No Bus:ep_00
[   71.709817] scsi 8:0:0:0: Direct-Access     WD       5000BEV External 1.=
75 PQ: 0 ANSI: 4
[   71.709843] PM: Adding info for scsi:target8:0:0
[   71.709902] PM: Adding info for scsi:8:0:0:0
[   71.709957] PM: Adding info for No Bus:8:0:0:0
[   71.709998] PM: Adding info for No Bus:8:0:0:0
[   71.710185] PM: Adding info for No Bus:sg2
[   71.710211] sd 8:0:0:0: Attached scsi generic sg2 type 0
[   71.710298] PM: Adding info for No Bus:8:0:0:0
[   71.710756] sd 8:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB=
/465 GiB)
[   71.711244] sd 8:0:0:0: [sdb] Write Protect is off
[   71.711251] sd 8:0:0:0: [sdb] Mode Sense: 23 00 00 00
[   71.711257] sd 8:0:0:0: [sdb] Assuming drive cache: write through
[   71.711302] PM: Adding info for No Bus:sdb
[   71.712493] sd 8:0:0:0: [sdb] Assuming drive cache: write through
[   71.712502]  sdb: sdb1
[   71.725300] PM: Adding info for No Bus:sdb1
[   71.725417] PM: Adding info for No Bus:8:16
[   71.726850] sd 8:0:0:0: [sdb] Assuming drive cache: write through
[   71.726857] sd 8:0:0:0: [sdb] Attached SCSI disk
[   73.061414] device eth0 left promiscuous mode
[   88.014158] device eth0 entered promiscuous mode
[  144.469624] device eth0 left promiscuous mode
[  149.152735] PM: Removing info for No Bus:eth0
[  151.987680] e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k4
[  151.987682] e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
[  151.987718] e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ=
 20
[  151.987729] e1000e 0000:00:19.0: setting latency timer to 64
[  151.987987] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[  152.112532] PM: Adding info for No Bus:eth0
[  152.112975] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 00=
:26:2d:f7:02:12
[  152.112979] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connect=
ion
[  152.113048] e1000e 0000:00:19.0: eth0: MAC: 9, PHY: 10, PBA No: a002ff-0=
ff
[  170.318212] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[  170.369007] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[  170.369614] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  174.727598] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Cont=
rol: RX
[  174.731179] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  185.253552] eth0: no IPv6 routers present
[10160.821404] PM: Removing info for No Bus:event5
[10160.826373] PM: Removing info for No Bus:input5
[31970.397849] usb 1-1.4: USB disconnect, address 10
[31970.397883] btusb_intr_complete: hci0 urb ffff8800bac59a80 failed to res=
ubmit (19)
[31970.397959] btusb_bulk_complete: hci0 urb ffff8800bac59480 failed to res=
ubmit (19)
[31970.397966] btusb_bulk_complete: hci0 urb ffff8800bac599c0 failed to res=
ubmit (19)
[31970.397980] PM: Removing info for No Bus:ep_81
[31970.397997] PM: Removing info for No Bus:ep_82
[31970.398007] PM: Removing info for No Bus:ep_02
[31970.398015] PM: Removing info for usb:1-1.4:1.0
[31970.398042] btusb_send_frame: hci0 urb ffff880019b8a240 submission failed
[31970.646932] PM: Removing info for No Bus:rfkill5
[31970.646997] PM: Removing info for No Bus:hci0
[31970.647091] PM: Removing info for No Bus:ep_83
[31970.647101] PM: Removing info for No Bus:ep_03
[31970.647109] PM: Removing info for usb:1-1.4:1.1
[31970.647128] PM: Removing info for No Bus:ep_84
[31970.647139] PM: Removing info for No Bus:ep_04
[31970.647148] PM: Removing info for usb:1-1.4:1.2
[31970.647165] PM: Removing info for usb:1-1.4:1.3
[31970.647182] PM: Removing info for No Bus:ep_00
[31970.647194] PM: Removing info for usb:1-1.4
[31971.639539] PM: Syncing filesystems ... done.
[31971.731924] PM: Preparing system for mem sleep
[31971.883297] Freezing user space processes ... (elapsed 0.01 seconds) don=
e.
[31971.893633] Freezing remaining freezable tasks ... (elapsed 0.01 seconds=
) done.
[31971.904579] PM: Entering mem sleep
[31971.904689] Suspending console(s) (use no_console_suspend to debug)
[31971.904723] platform dock.0: preparing suspend
[31971.904724] platform dock.1: preparing suspend
[31971.904726] platform dock.2: preparing suspend
[31971.904729] pci 0000:ff:00.0: preparing suspend
[31971.904730] pci 0000:ff:00.1: preparing suspend
[31971.904732] pci 0000:ff:02.0: preparing suspend
[31971.904733] pci 0000:ff:02.1: preparing suspend
[31971.904735] pci 0000:ff:02.2: preparing suspend
[31971.904736] pci 0000:ff:02.3: preparing suspend
[31971.904739] agpgart-intel 0000:00:00.0: preparing suspend
[31971.904740] i915 0000:00:02.0: preparing suspend
[31971.904742] pci 0000:00:16.0: preparing suspend
[31971.904744] serial 0000:00:16.3: preparing suspend
[31971.904746] e1000e 0000:00:19.0: preparing suspend, may wakeup
[31971.904748] ehci_hcd 0000:00:1a.0: preparing suspend
[31971.904754] HDA Intel 0000:00:1b.0: preparing suspend
[31971.904756] pcieport 0000:00:1c.0: preparing suspend
[31971.904757] pcieport 0000:00:1c.3: preparing suspend
[31971.904759] pcieport 0000:00:1c.4: preparing suspend
[31971.904763] ehci_hcd 0000:00:1d.0: preparing suspend
[31971.904765] pci 0000:00:1e.0: preparing suspend
[31971.904766] pci 0000:00:1f.0: preparing suspend
[31971.904768] ahci 0000:00:1f.2: preparing suspend
[31971.904770] i801_smbus 0000:00:1f.3: preparing suspend
[31971.904771] pci 0000:00:1f.6: preparing suspend
[31971.904774] iwlagn 0000:02:00.0: preparing suspend
[31971.904780] platform pcspkr: preparing suspend
[31971.904782] platform microcode: preparing suspend
[31971.904867] i8042 i8042: preparing suspend
[31971.904876] platform regulatory.0: preparing suspend
[31971.904878] serial8250 serial8250: preparing suspend
[31971.904881] usb usb1: preparing type suspend, may wakeup
[31971.904884] usb usb2: preparing type suspend, may wakeup
[31971.904891] thinkpad_acpi thinkpad_acpi: preparing suspend
[31971.904892] thinkpad_hwmon thinkpad_hwmon: preparing suspend
[31971.904898] usb 1-1: preparing type suspend
[31971.904900] usb 2-1: preparing type suspend
[31971.904903] usb 1-1.3: preparing type suspend
[31971.904906] usb 1-1.6: preparing type suspend
[31971.904936] usb 1-1.5: preparing type suspend
[31971.904940] usb 1-1.5.2: preparing type suspend
[31971.904962] acpi IBM0079:02: legacy suspend
[31971.904964] acpi device:34: legacy suspend
[31971.904966] acpi LNXIOBAY:02: legacy suspend
[31971.904971] input input9: type suspend
[31971.904974] backlight acpi_video0: legacy class suspend
[31971.904976] i2c i2c-4: suspend
[31971.904979] drm card0-DisplayPort-1: legacy class suspend
[31971.904981] drm card0-HDMI Type A-1: legacy class suspend
[31971.904983] i2c i2c-3: suspend
[31971.904985] drm card0-LVDS-1: legacy class suspend
[31971.904987] i2c i2c-2: suspend
[31971.904989] drm card0-VGA-1: legacy class suspend
[31971.904991] i2c i2c-1: suspend
[31971.904993] sd 8:0:0:0: legacy suspend
[31971.904996] drm card0: legacy class suspend
[31971.904998] drm controlD64: legacy class suspend
[31971.905003] scsi target8:0:0: legacy suspend
[31971.905007] scsi host8: legacy suspend
[31971.905018] usb 1-1.5.2: type suspend
[31971.905021] sr 1:0:0:0: legacy suspend
[31971.905024] scsi target1:0:0: legacy suspend
[31971.905026] usb 1-1.5: type suspend
[31971.905048] input input8: type suspend
[31971.905051] input input7: type suspend
[31971.905076] usb 1-1.6: type suspend
[31971.905089] usb 1-1.3: type suspend
[31971.905093] rfkill rfkill1: legacy class suspend
[31971.905096] ieee80211 phy0: legacy class suspend
[31971.916843] usb 2-1: type suspend
[31971.916888] usb 1-1: type suspend
[31971.916893] input input6: type suspend
[31971.916900] leds tpacpi::thinkvantage: legacy class suspend
[31971.916905] leds tpacpi::unknown_led3: legacy class suspend
[31971.916909] leds tpacpi::unknown_led2: legacy class suspend
[31971.916913] leds tpacpi::dock_status2: legacy class suspend
[31971.916917] leds tpacpi::dock_status1: legacy class suspend
[31971.916921] leds tpacpi::standby: legacy class suspend
[31971.916925] leds tpacpi::unknown_led: legacy class suspend
[31971.916929] leds tpacpi::dock_batt: legacy class suspend
[31971.916933] leds tpacpi::bay_active: legacy class suspend
[31971.916937] leds tpacpi::dock_active: legacy class suspend
[31971.916942] leds tpacpi:green:batt: legacy class suspend
[31971.916947] leds tpacpi:orange:batt: legacy class suspend
[31971.916955] leds tpacpi::power: legacy class suspend
[31971.916957] leds tpacpi::thinklight: legacy class suspend
[31971.916959] rfkill rfkill0: legacy class suspend
[31971.916961] thinkpad_hwmon thinkpad_hwmon: suspend
[31971.916965] thinkpad_acpi thinkpad_acpi: suspend
[31971.916990] usb usb2: type suspend, may wakeup
[31971.917005] usb usb1: type suspend, may wakeup
[31971.917007] i2c i2c-0: suspend
[31971.917013] serial8250 serial8250: suspend
[31971.917015] platform regulatory.0: suspend
[31971.917019] psmouse serio2: suspend
[31972.100145] input input4: type suspend
[31972.100168] input input3: type suspend
[31972.100172] sd 0:0:0:0: legacy suspend
[31972.100176] psmouse serio1: suspend
[31972.100179] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[31972.140888] sd 0:0:0:0: [sda] Stopping disk
[31972.152752] atkbd serio0: suspend
[31972.153276] i8042 i8042: suspend
[31972.153836] scsi host5: legacy suspend
[31972.153844] scsi host4: legacy suspend
[31972.153848] scsi host3: legacy suspend
[31972.153851] scsi host2: legacy suspend
[31972.153854] scsi host1: legacy suspend
[31972.153984] input input2: type suspend
[31972.153986] input input1: type suspend
[31972.153987] input input0: type suspend
[31972.153991] platform microcode: suspend
[31972.153993] platform pcspkr: suspend
[31972.153997] system 00:0c: legacy suspend
[31972.153999] ACPI handle has no context!
[31972.154003] tpm_tis 00:0b: legacy suspend
[31972.345794] i8042 aux 00:0a: legacy suspend
[31972.345806] i8042 kbd 00:09: legacy suspend
[31972.345817] rtc_cmos 00:08: legacy suspend, may wakeup
[31972.345831] pnp 00:07: legacy suspend
[31972.345834] pnp 00:06: legacy suspend
[31972.345836] pnp 00:05: legacy suspend
[31972.345839] pnp 00:04: legacy suspend
[31972.345841] system 00:03: legacy suspend
[31972.345853] pnp 00:02: legacy suspend
[31972.345856] pnp 00:01: legacy suspend
[31972.345858] system 00:00: legacy suspend
[31972.345920] iwlagn 0000:02:00.0: suspend
[31972.345933] pci 0000:00:1f.6: suspend
[31972.345936] i801_smbus 0000:00:1f.3: suspend
[31972.345940] pci 0000:00:1f.0: suspend
[31972.345995] pci 0000:00:1e.0: suspend
[31972.346055] ehci_hcd 0000:00:1d.0: suspend
[31972.346159] ehci_hcd 0000:00:1d.0: PCI INT D disabled
[31972.346163] pcieport 0000:00:1c.3: suspend
[31972.346231] pcieport 0000:00:1c.0: suspend
[31972.346283] HDA Intel 0000:00:1b.0: suspend
[31972.346333] ehci_hcd 0000:00:1a.0: suspend
[31972.346394] e1000e 0000:00:19.0: suspend, may wakeup
[31972.346444] ehci_hcd 0000:00:1a.0: PCI INT D disabled
[31972.346447] serial 0000:00:16.3: suspend
[31972.346568] pci 0000:00:16.0: suspend
[31972.346573] i915 0000:00:02.0: suspend
[31972.346727] ACPI handle has no context!
[31972.346749] agpgart-intel 0000:00:00.0: suspend
[31972.346760] pci 0000:ff:02.3: suspend
[31972.346762] platform dock.2: suspend
[31972.346764] pci 0000:ff:02.2: suspend
[31972.346766] platform dock.1: suspend
[31972.346768] platform dock.0: suspend
[31972.346770] pci 0000:ff:02.1: suspend
[31972.346772] button LNXPWRBN:00: legacy suspend
[31972.346774] pci 0000:ff:02.0: suspend
[31972.346776] thermal LNXTHERM:01: legacy suspend
[31972.346778] pci 0000:ff:00.1: suspend
[31972.346780] pci 0000:ff:00.0: suspend
[31972.346782] acpi LNXTHERM:00: legacy suspend
[31972.346785] wmi PNP0C14:00: legacy suspend
[31972.346788] acpi PNP0C02:01: legacy suspend
[31972.346790] acpi device:32: legacy suspend
[31972.346792] acpi device:31: legacy suspend
[31972.346795] acpi device:2f: legacy suspend
[31972.346797] acpi device:2e: legacy suspend
[31972.346799] acpi device:2d: legacy suspend
[31972.346801] acpi device:2c: legacy suspend
[31972.346805] acpi device:2b: legacy suspend
[31972.346807] acpi device:2a: legacy suspend
[31972.346809] acpi device:29: legacy suspend
[31972.346811] acpi device:28: legacy suspend
[31972.346813] acpi device:27: legacy suspend
[31972.346815] acpi device:26: legacy suspend
[31972.346817] acpi device:25: legacy suspend
[31972.346819] acpi device:24: legacy suspend
[31972.346821] acpi device:23: legacy suspend
[31972.346823] acpi device:22: legacy suspend
[31972.346824] acpi device:21: legacy suspend
[31972.346827] acpi device:20: legacy suspend
[31972.346828] acpi device:1f: legacy suspend
[31972.346830] acpi device:1e: legacy suspend
[31972.346832] acpi device:1d: legacy suspend
[31972.346833] acpi device:1c: legacy suspend
[31972.346835] acpi device:1b: legacy suspend
[31972.346836] acpi device:1a: legacy suspend
[31972.346838] acpi device:19: legacy suspend
[31972.346840] acpi device:18: legacy suspend
[31972.346841] acpi device:17: legacy suspend
[31972.346843] acpi device:16: legacy suspend
[31972.346844] acpi device:15: legacy suspend
[31972.346847] acpi device:14: legacy suspend
[31972.346848] acpi device:13: legacy suspend
[31972.346850] acpi device:12: legacy suspend
[31972.346851] acpi device:11: legacy suspend
[31972.346853] acpi device:10: legacy suspend
[31972.346854] acpi device:0f: legacy suspend
[31972.346856] acpi device:0e: legacy suspend
[31972.346857] acpi device:0d: legacy suspend
[31972.346859] acpi device:0c: legacy suspend
[31972.346860] acpi device:0b: legacy suspend
[31972.346862] acpi LNXVIDEO:01: legacy suspend
[31972.346863] acpi device:0a: legacy suspend
[31972.346866] thinkpad_hotkey IBM0068:00: legacy suspend
[31972.346867] ac ACPI0003:00: legacy suspend
[31972.346870] battery PNP0C0A:00: legacy suspend
[31972.346871] power LNXPOWER:00: legacy suspend
[31972.346874] ec PNP0C09:00: legacy suspend
[31972.346879] acpi SMO1200:00: legacy suspend
[31972.346881] acpi LEN0018:00: legacy suspend
[31972.346882] acpi PNP0303:00: legacy suspend
[31972.346884] acpi PNP0B00:00: legacy suspend
[31972.346885] acpi PNP0C04:00: legacy suspend
[31972.346887] acpi PNP0800:00: legacy suspend
[31972.346888] acpi PNP0200:00: legacy suspend
[31972.346890] acpi PNP0103:00: legacy suspend
[31972.346891] acpi PNP0100:00: legacy suspend
[31972.346893] acpi PNP0000:00: legacy suspend
[31972.346894] acpi PNP0C02:00: legacy suspend
[31972.346897] acpi device:09: legacy suspend
[31972.346898] acpi device:08: legacy suspend
[31972.346900] acpi device:07: legacy suspend
[31972.346901] acpi device:06: legacy suspend
[31972.346903] acpi device:05: legacy suspend
[31972.346904] acpi device:04: legacy suspend
[31972.346905] acpi device:03: legacy suspend
[31972.346907] acpi device:02: legacy suspend
[31972.346908] acpi device:01: legacy suspend
[31972.346911] video LNXVIDEO:00: legacy suspend
[31972.346914] pci_root PNP0A08:00: legacy suspend
[31972.346916] acpi device:00: legacy suspend
[31972.346918] pci_root PNP0A03:00: legacy suspend
[31972.346919] button PNP0C0E:00: legacy suspend
[31972.346921] button PNP0C0D:00: legacy suspend
[31972.346923] acpi PNP0C01:00: legacy suspend
[31972.346924] pci_link PNP0C0F:07: legacy suspend
[31972.346926] pci_link PNP0C0F:06: legacy suspend
[31972.346928] pci_link PNP0C0F:05: legacy suspend
[31972.346929] pci_link PNP0C0F:04: legacy suspend
[31972.346931] pci_link PNP0C0F:03: legacy suspend
[31972.346933] pci_link PNP0C0F:02: legacy suspend
[31972.346934] pci_link PNP0C0F:01: legacy suspend
[31972.346936] pci_link PNP0C0F:00: legacy suspend
[31972.346939] acpi LNXSYBUS:00: legacy suspend
[31972.346941] processor LNXCPU:07: legacy suspend
[31972.346945] processor LNXCPU:06: legacy suspend
[31972.346946] processor LNXCPU:05: legacy suspend
[31972.346948] processor LNXCPU:04: legacy suspend
[31972.346949] processor LNXCPU:03: legacy suspend
[31972.346951] processor LNXCPU:02: legacy suspend
[31972.346953] processor LNXCPU:01: legacy suspend
[31972.346954] processor LNXCPU:00: legacy suspend
[31972.346957] acpi LNXSYSTM:00: legacy suspend
[31972.357675] pcieport 0000:00:1c.4: suspend
[31972.362088] i915 0000:00:02.0: power state changed by ACPI to D3
[31972.446878] HDA Intel 0000:00:1b.0: PCI INT B disabled
[31972.527355] e1000e 0000:00:19.0: PME# enabled
[31972.527366] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
[31972.529644] scsi target0:0:0: legacy suspend
[31972.529650] scsi host0: legacy suspend
[31972.529659] ahci 0000:00:1f.2: suspend
[31972.595200] PM: suspend of devices complete after 691.571 msecs
[31972.595239] usb 1-1.5.2: LATE type suspend
[31972.595242] usb 1-1.5: LATE type suspend
[31972.595245] input input9: LATE type suspend
[31972.595248] i2c i2c-4: LATE suspend
[31972.595250] i2c i2c-3: LATE suspend
[31972.595252] i2c i2c-2: LATE suspend
[31972.595254] i2c i2c-1: LATE suspend
[31972.595266] input input8: LATE type suspend
[31972.595268] input input7: LATE type suspend
[31972.595271] usb 1-1.6: LATE type suspend
[31972.595273] usb 1-1.3: LATE type suspend
[31972.595276] usb 2-1: LATE type suspend
[31972.595278] usb 1-1: LATE type suspend
[31972.595280] input input6: LATE type suspend
[31972.595285] thinkpad_hwmon thinkpad_hwmon: LATE suspend
[31972.595288] thinkpad_acpi thinkpad_acpi: LATE suspend
[31972.595292] usb usb2: LATE type suspend, may wakeup
[31972.595294] usb usb1: LATE type suspend, may wakeup
[31972.595297] i2c i2c-0: LATE suspend
[31972.595299] serial8250 serial8250: LATE suspend
[31972.595301] platform regulatory.0: LATE suspend
[31972.595304] psmouse serio2: LATE suspend
[31972.595306] input input4: LATE type suspend
[31972.595313] input input3: LATE type suspend
[31972.595316] psmouse serio1: LATE suspend
[31972.595318] atkbd serio0: LATE suspend
[31972.595320] i8042 i8042: LATE suspend
[31972.595353] input input2: LATE type suspend
[31972.595356] input input1: LATE type suspend
[31972.595358] input input0: LATE type suspend
[31972.595360] platform microcode: LATE suspend
[31972.595363] platform pcspkr: LATE suspend
[31972.595367] iwlagn 0000:02:00.0: LATE suspend
[31972.595370] pci 0000:00:1f.6: LATE suspend
[31972.595404] i801_smbus 0000:00:1f.3: LATE suspend
[31972.595406] ahci 0000:00:1f.2: LATE suspend
[31972.595408] pci 0000:00:1f.0: LATE suspend
[31972.595440] pci 0000:00:1e.0: LATE suspend
[31972.595470] ehci_hcd 0000:00:1d.0: LATE suspend
[31972.608365] ehci_hcd 0000:00:1d.0: power state changed by ACPI to D3
[31972.608371] pcieport 0000:00:1c.4: LATE suspend
[31972.608421] pcieport 0000:00:1c.3: LATE suspend
[31972.608469] pcieport 0000:00:1c.0: LATE suspend
[31972.608518] HDA Intel 0000:00:1b.0: LATE suspend
[31972.608520] ehci_hcd 0000:00:1a.0: LATE suspend
[31972.626302] ehci_hcd 0000:00:1a.0: power state changed by ACPI to D3
[31972.626307] e1000e 0000:00:19.0: LATE suspend, may wakeup
[31972.626310] serial 0000:00:16.3: LATE suspend
[31972.626312] pci 0000:00:16.0: LATE suspend
[31972.626345] i915 0000:00:02.0: LATE suspend
[31972.626347] agpgart-intel 0000:00:00.0: LATE suspend
[31972.626359] pci 0000:ff:02.3: LATE suspend
[31972.626367] pci 0000:ff:02.2: LATE suspend
[31972.626375] pci 0000:ff:02.1: LATE suspend
[31972.626383] pci 0000:ff:02.0: LATE suspend
[31972.626391] pci 0000:ff:00.1: LATE suspend
[31972.626399] pci 0000:ff:00.0: LATE suspend
[31972.626407] platform dock.2: LATE suspend
[31972.626409] platform dock.1: LATE suspend
[31972.626412] platform dock.0: LATE suspend
[31972.626420] PM: late suspend of devices complete after 31.276 msecs
[31972.636286] ACPI: Preparing to enter system sleep state S3
[31972.676249] PM: Saving platform NVS memory
[31972.808116] Disabling non-boot CPUs ...
[31972.821107] CPU 1 is now offline
[31972.836931] CPU 2 is now offline
[31972.852874] CPU 3 is now offline
[31972.852876] SMP alternatives: switching to UP code
[31972.856268] Extended CMOS year: 2000
[18446744058.756090] Back to C!
[18446744058.756094] PM: Restoring platform NVS memory
[18446744058.893458] Extended CMOS year: 2000
[18446744058.893476] Enabling non-boot CPUs ...
[18446744058.893952] SMP alternatives: switching to SMP code
[18446744058.896948] Booting Node 0 Processor 1 APIC 0x1
[18446744058.996831] CPU1 is up
[18446744058.996966] Booting Node 0 Processor 2 APIC 0x4
[18446744059.103753] CPU2 is up
[18446744059.103883] Booting Node 0 Processor 3 APIC 0x5
[18446744059.210550] CPU3 is up
[18446744059.211965] ACPI: Waking up from system sleep state S3
[18446744059.300383] thinkpad_acpi: EC reports that Thermal Table has chang=
ed
[18446744059.328409] PM: Removing info for acpi:LNXIOBAY:02
[18446744059.328447] PM: Removing info for acpi:device:34
[18446744059.328480] PM: Removing info for acpi:IBM0079:02
[18446744059.328499] ACPI: \_SB_.GDCK - undocking
[18446744059.329507] ACPI: \_SB_.PCI0.SAT1.PRT1 - docking
[18446744059.329631] ACPI: Unable to dock!
[18446744059.331296] platform dock.0: EARLY resume
[18446744059.331300] platform dock.1: EARLY resume
[18446744059.331302] platform dock.2: EARLY resume
[18446744059.331305] pci 0000:ff:00.0: EARLY resume
[18446744059.331319] pci 0000:ff:00.1: EARLY resume
[18446744059.331330] pci 0000:ff:02.0: EARLY resume
[18446744059.331339] pci 0000:ff:02.1: EARLY resume
[18446744059.331349] pci 0000:ff:02.2: EARLY resume
[18446744059.331358] pci 0000:ff:02.3: EARLY resume
[18446744059.331368] agpgart-intel 0000:00:00.0: EARLY resume
[18446744059.331383] i915 0000:00:02.0: EARLY resume
[18446744059.331397] i915 0000:00:02.0: restoring config space at offset 0x=
1 (was 0x900007, writing 0x900407)
[18446744059.331411] pci 0000:00:16.0: EARLY resume
[18446744059.331455] serial 0000:00:16.3: EARLY resume
[18446744059.331499] e1000e 0000:00:19.0: EARLY resume
[18446744059.331549] ehci_hcd 0000:00:1a.0: EARLY resume
[18446744059.331566] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.331587] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728000)
[18446744059.331596] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.342203] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.344213] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.344218] HDA Intel 0000:00:1b.0: EARLY resume
[18446744059.344270] pcieport 0000:00:1c.0: EARLY resume
[18446744059.344313] pcieport 0000:00:1c.0: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.344347] pcieport 0000:00:1c.3: EARLY resume
[18446744059.344388] pcieport 0000:00:1c.3: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.344421] pcieport 0000:00:1c.4: EARLY resume
[18446744059.344443] pcieport 0000:00:1c.4: restoring config space at offse=
t 0xf (was 0x100, writing 0x4010b)
[18446744059.344457] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x9 (was 0x10001, writing 0x1fff1)
[18446744059.344464] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x8 (was 0x0, writing 0xf240f240)
[18446744059.344471] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x7 (was 0x0, writing 0xf0)
[18446744059.344481] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x3 (was 0x810000, writing 0x810010)
[18446744059.344489] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x1 (was 0x100000, writing 0x100507)
[18446744059.344522] ehci_hcd 0000:00:1d.0: EARLY resume
[18446744059.344540] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.344560] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728400)
[18446744059.344570] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.346208] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.348204] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.348210] pci 0000:00:1e.0: EARLY resume
[18446744059.348247] pci 0000:00:1f.0: EARLY resume
[18446744059.348285] ahci 0000:00:1f.2: EARLY resume
[18446744059.348324] ahci 0000:00:1f.2: restoring config space at offset 0x=
1 (was 0x2b00007, writing 0x2b00407)
[18446744059.348355] i801_smbus 0000:00:1f.3: EARLY resume
[18446744059.348385] pci 0000:00:1f.6: EARLY resume
[18446744059.348400] pci 0000:00:1f.6: restoring config space at offset 0xf=
 (was 0x400, writing 0x40b)
[18446744059.348425] pci 0000:00:1f.6: restoring config space at offset 0x1=
 (was 0x100000, writing 0x100002)
[18446744059.348441] iwlagn 0000:02:00.0: EARLY resume
[18446744059.348514] iwlagn 0000:02:00.0: restoring config space at offset =
0x1 (was 0x100106, writing 0x100506)
[18446744059.348575] platform pcspkr: EARLY resume
[18446744059.348577] platform microcode: EARLY resume
[18446744059.348581] input input0: EARLY type resume
[18446744059.348584] input input1: EARLY type resume
[18446744059.348586] input input2: EARLY type resume
[18446744059.348636] i8042 i8042: EARLY resume
[18446744059.348638] atkbd serio0: EARLY resume
[18446744059.348641] psmouse serio1: EARLY resume
[18446744059.348644] input input3: EARLY type resume
[18446744059.348648] input input4: EARLY type resume
[18446744059.348651] psmouse serio2: EARLY resume
[18446744059.348654] platform regulatory.0: EARLY resume
[18446744059.348656] serial8250 serial8250: EARLY resume
[18446744059.348660] i2c i2c-0: EARLY resume
[18446744059.348663] usb usb1: EARLY type resume
[18446744059.348665] usb usb2: EARLY type resume
[18446744059.348671] thinkpad_acpi thinkpad_acpi: EARLY resume
[18446744059.348674] thinkpad_hwmon thinkpad_hwmon: EARLY resume
[18446744059.348678] input input6: EARLY type resume
[18446744059.348681] usb 1-1: EARLY type resume
[18446744059.348684] usb 2-1: EARLY type resume
[18446744059.348687] usb 1-1.3: EARLY type resume
[18446744059.348691] usb 1-1.6: EARLY type resume
[18446744059.348694] input input7: EARLY type resume
[18446744059.348696] input input8: EARLY type resume
[18446744059.348713] i2c i2c-1: EARLY resume
[18446744059.348715] i2c i2c-2: EARLY resume
[18446744059.348717] i2c i2c-3: EARLY resume
[18446744059.348720] i2c i2c-4: EARLY resume
[18446744059.348723] input input9: EARLY type resume
[18446744059.348726] usb 1-1.5: EARLY type resume
[18446744059.348730] usb 1-1.5.2: EARLY type resume
[18446744059.348735] PM: early resume of devices complete after 17.483 msecs
[18446744059.348798] pci 0000:ff:00.0: resume
[18446744059.348806] pci 0000:ff:00.1: resume
[18446744059.348813] pci 0000:ff:02.0: resume
[18446744059.348842] pci 0000:ff:02.1: resume
[18446744059.348858] pci 0000:ff:02.2: resume
[18446744059.348875] pci 0000:ff:02.3: resume
[18446744059.348907] agpgart-intel 0000:00:00.0: resume
[18446744059.348924] i915 0000:00:02.0: resume
[18446744059.348942] pci 0000:00:16.0: resume
[18446744059.348953] serial 0000:00:16.3: resume
[18446744059.348969] e1000e 0000:00:19.0: resume
[18446744059.348984] ehci_hcd 0000:00:1a.0: resume
[18446744059.348987] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.349003] HDA Intel 0000:00:1b.0: resume
[18446744059.349005] e1000e 0000:00:19.0: wake-up capability disabled by AC=
PI
[18446744059.349013] e1000e 0000:00:19.0: PME# disabled
[18446744059.349024] pcieport 0000:00:1c.0: resume
[18446744059.349046] pcieport 0000:00:1c.3: resume
[18446744059.349074] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, lo=
w) -> IRQ 17
[18446744059.349077] pcieport 0000:00:1c.4: resume
[18446744059.349084] HDA Intel 0000:00:1b.0: setting latency timer to 64
[18446744059.349096] ehci_hcd 0000:00:1d.0: resume
[18446744059.349111] pci 0000:00:1e.0: resume
[18446744059.349126] pci 0000:00:1f.0: resume
[18446744059.349145] e1000e 0000:00:19.0: irq 44 for MSI/MSI-X
[18446744059.349147] ahci 0000:00:1f.2: resume
[18446744059.349152] HDA Intel 0000:00:1b.0: irq 45 for MSI/MSI-X
[18446744059.349165] i801_smbus 0000:00:1f.3: resume
[18446744059.349181] pci 0000:00:1f.6: resume
[18446744059.349196] iwlagn 0000:02:00.0: resume
[18446744059.349248] pci 0000:00:1e.0: setting latency timer to 64
[18446744059.349429] ahci 0000:00:1f.2: setting latency timer to 64
[18446744059.349472] acpi LNXSYSTM:00: legacy resume
[18446744059.349475] processor LNXCPU:00: legacy resume
[18446744059.349479] processor LNXCPU:01: legacy resume
[18446744059.349498] ata2.00: disabled
[18446744059.349506] scsi host5: legacy resume
[18446744059.349540] scsi host1: legacy resume
[18446744059.349545] scsi host2: legacy resume
[18446744059.349549] scsi host3: legacy resume
[18446744059.349553] scsi host4: legacy resume
[18446744059.349560] processor LNXCPU:02: legacy resume
[18446744059.349563] processor LNXCPU:03: legacy resume
[18446744059.349565] processor LNXCPU:04: legacy resume
[18446744059.349568] processor LNXCPU:05: legacy resume
[18446744059.349570] processor LNXCPU:06: legacy resume
[18446744059.349573] processor LNXCPU:07: legacy resume
[18446744059.349575] acpi LNXSYBUS:00: legacy resume
[18446744059.349578] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.349580] pci_link PNP0C0F:00: legacy resume
[18446744059.349583] pci_link PNP0C0F:01: legacy resume
[18446744059.349585] i915 0000:00:02.0: setting latency timer to 64
[18446744059.349587] pci_link PNP0C0F:02: legacy resume
[18446744059.349590] pci_link PNP0C0F:03: legacy resume
[18446744059.349591] pci_link PNP0C0F:04: legacy resume
[18446744059.349593] pci_link PNP0C0F:05: legacy resume
[18446744059.349596] pci_link PNP0C0F:06: legacy resume
[18446744059.349598] pci_link PNP0C0F:07: legacy resume
[18446744059.349600] acpi PNP0C01:00: legacy resume
[18446744059.349602] button PNP0C0D:00: legacy resume
[18446744059.349829] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.349832] scsi host0: legacy resume
[18446744059.349837] scsi target0:0:0: legacy resume
[18446744059.349841] sd 0:0:0:0: legacy resume
[18446744059.349845] sd 0:0:0:0: [sda] Starting disk
[18446744059.350028] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.350158] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.350167] ehci_hcd 0000:00:1a.0: PCI INT D -> GSI 23 (level, low=
) -> IRQ 23
[18446744059.350177] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[18446744059.350218] usb usb1: type resume
[18446744059.350389] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.350397] ehci_hcd 0000:00:1d.0: PCI INT D -> GSI 19 (level, low=
) -> IRQ 19
[18446744059.350406] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[18446744059.350453] usb usb2: type resume
[18446744059.350554] button PNP0C0E:00: legacy resume
[18446744059.350556] pci_root PNP0A03:00: legacy resume
[18446744059.350558] acpi device:00: legacy resume
[18446744059.350560] pci_root PNP0A08:00: legacy resume
[18446744059.350562] video LNXVIDEO:00: legacy resume
[18446744059.350564] acpi device:01: legacy resume
[18446744059.350565] acpi device:02: legacy resume
[18446744059.350567] acpi device:03: legacy resume
[18446744059.350569] acpi device:04: legacy resume
[18446744059.350570] acpi device:05: legacy resume
[18446744059.350572] acpi device:06: legacy resume
[18446744059.350574] acpi device:07: legacy resume
[18446744059.350575] acpi device:08: legacy resume
[18446744059.350577] acpi device:09: legacy resume
[18446744059.350579] acpi PNP0C02:00: legacy resume
[18446744059.350581] acpi PNP0000:00: legacy resume
[18446744059.350582] acpi PNP0100:00: legacy resume
[18446744059.350584] acpi PNP0103:00: legacy resume
[18446744059.350586] acpi PNP0200:00: legacy resume
[18446744059.350587] acpi PNP0800:00: legacy resume
[18446744059.350589] acpi PNP0C04:00: legacy resume
[18446744059.350591] acpi PNP0B00:00: legacy resume
[18446744059.350592] acpi PNP0303:00: legacy resume
[18446744059.350594] acpi LEN0018:00: legacy resume
[18446744059.350596] acpi SMO1200:00: legacy resume
[18446744059.350597] ec PNP0C09:00: legacy resume
[18446744059.350604] power LNXPOWER:00: legacy resume
[18446744059.350789] battery PNP0C0A:00: legacy resume
[18446744059.367065] ac ACPI0003:00: legacy resume
[18446744059.367252] thinkpad_hotkey IBM0068:00: legacy resume
[18446744059.367254] acpi device:0a: legacy resume
[18446744059.367256] acpi LNXVIDEO:01: legacy resume
[18446744059.367257] acpi device:0b: legacy resume
[18446744059.367259] acpi device:0c: legacy resume
[18446744059.367261] acpi device:0d: legacy resume
[18446744059.367262] acpi device:0e: legacy resume
[18446744059.367264] acpi device:0f: legacy resume
[18446744059.367266] acpi device:10: legacy resume
[18446744059.367267] acpi device:11: legacy resume
[18446744059.367269] acpi device:12: legacy resume
[18446744059.367271] acpi device:13: legacy resume
[18446744059.367272] acpi device:14: legacy resume
[18446744059.367274] acpi device:15: legacy resume
[18446744059.367276] acpi device:16: legacy resume
[18446744059.367277] acpi device:17: legacy resume
[18446744059.367279] acpi device:18: legacy resume
[18446744059.367281] acpi device:19: legacy resume
[18446744059.367282] acpi device:1a: legacy resume
[18446744059.367284] acpi device:1b: legacy resume
[18446744059.367286] acpi device:1c: legacy resume
[18446744059.367287] acpi device:1d: legacy resume
[18446744059.367289] acpi device:1e: legacy resume
[18446744059.367291] acpi device:1f: legacy resume
[18446744059.367292] acpi device:20: legacy resume
[18446744059.367294] acpi device:21: legacy resume
[18446744059.367296] acpi device:22: legacy resume
[18446744059.367297] acpi device:23: legacy resume
[18446744059.367299] acpi device:24: legacy resume
[18446744059.367301] acpi device:25: legacy resume
[18446744059.367302] acpi device:26: legacy resume
[18446744059.367304] acpi device:27: legacy resume
[18446744059.367306] acpi device:28: legacy resume
[18446744059.367307] acpi device:29: legacy resume
[18446744059.367309] acpi device:2a: legacy resume
[18446744059.367310] acpi device:2b: legacy resume
[18446744059.367312] acpi device:2c: legacy resume
[18446744059.367314] acpi device:2d: legacy resume
[18446744059.367315] acpi device:2e: legacy resume
[18446744059.367317] acpi device:2f: legacy resume
[18446744059.367319] acpi device:31: legacy resume
[18446744059.367320] acpi device:32: legacy resume
[18446744059.367322] acpi PNP0C02:01: legacy resume
[18446744059.367324] wmi PNP0C14:00: legacy resume
[18446744059.367326] acpi LNXTHERM:00: legacy resume
[18446744059.367328] thermal LNXTHERM:01: legacy resume
[18446744059.367854] button LNXPWRBN:00: legacy resume
[18446744059.367856] platform dock.0: resume
[18446744059.367858] platform dock.1: resume
[18446744059.367859] platform dock.2: resume
[18446744059.367865] system 00:00: legacy resume
[18446744059.367868] pnp 00:01: legacy resume
[18446744059.367869] pnp 00:02: legacy resume
[18446744059.367871] system 00:03: legacy resume
[18446744059.367874] pnp 00:04: legacy resume
[18446744059.367875] pnp 00:05: legacy resume
[18446744059.367877] pnp 00:06: legacy resume
[18446744059.367879] pnp 00:07: legacy resume
[18446744059.367880] rtc_cmos 00:08: legacy resume
[18446744059.367884] i8042 kbd 00:09: legacy resume
[18446744059.367886] i8042 aux 00:0a: legacy resume
[18446744059.367889] tpm_tis 00:0b: legacy resume
[18446744059.367891] system 00:0c: legacy resume
[18446744059.367896] platform pcspkr: resume
[18446744059.367898] platform microcode: resume
[18446744059.367901] input input0: type resume
[18446744059.367903] input input1: type resume
[18446744059.367905] input input2: type resume
[18446744059.367998] i8042 i8042: resume
[18446744059.368765] atkbd serio0: resume
[18446744059.368769] psmouse serio1: resume
[18446744059.368773] input input3: type resume
[18446744059.386269] scsi target1:0:0: legacy resume
[18446744059.386273] sr 1:0:0:0: legacy resume
[18446744059.391021] usb 1-1: type resume
[18446744059.391024] usb 2-1: type resume
[18446744059.491854] usb 1-1.3: type resume
[18446744059.491881] usb 1-1.6: type resume
[18446744059.491885] usb 1-1.5: type resume
[18446744059.492405] usb 1-1.5.2: type resume
[18446744059.492421] scsi host8: legacy resume
[18446744059.492435] scsi target8:0:0: legacy resume
[18446744059.492445] sd 8:0:0:0: legacy resume
[18446744059.564821] usb 1-1.3: reset full speed USB device using ehci_hcd =
and address 3
[18446744059.656642] ata2: SATA link down (SStatus 0 SControl 300)
[18446744059.658621] ata5: SATA link down (SStatus 0 SControl 300)
[18446744059.660510] ata6: SATA link down (SStatus 0 SControl 300)
[18446744059.667500] ata2.00: detaching (SCSI 1:0:0:0)
[18446744059.667513] PM: Removing info for No Bus:1:0:0:0
[18446744059.667619] PM: Removing info for No Bus:1:0:0:0
[18446744059.667628] PM: Removing info for No Bus:sg1
[18446744059.667669] PM: Removing info for scsi:1:0:0:0
[18446744059.675476] PM: Removing info for No Bus:11:0
[18446744059.675524] PM: Removing info for No Bus:sr0
[18446744059.675628] PM: Removing info for scsi:target1:0:0
[18446744059.724576] usb 1-1.6: reset high speed USB device using ehci_hcd =
and address 6
[18446744061.794432] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[18446744061.796792] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.796798] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.796803] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.801570] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.801577] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.801581] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.803656] ata1.00: configured for UDMA/100
[18446744061.818989] ata1.00: configured for UDMA/100
[18446744061.818994] ata1: EH complete
[18446744061.845110] input input4: type resume
[18446744061.845115] psmouse serio2: resume
[18446744061.845125] platform regulatory.0: resume
[18446744061.845129] serial8250 serial8250: resume
[18446744061.845139] i2c i2c-0: resume
[18446744061.845161] thinkpad_acpi thinkpad_acpi: resume
[18446744061.848326] thinkpad_hwmon thinkpad_hwmon: resume
[18446744061.848330] rfkill rfkill0: legacy class resume
[18446744061.848333] leds tpacpi::thinklight: legacy class resume
[18446744061.848336] leds tpacpi::power: legacy class resume
[18446744061.848338] leds tpacpi:orange:batt: legacy class resume
[18446744061.848340] leds tpacpi:green:batt: legacy class resume
[18446744061.848342] leds tpacpi::dock_active: legacy class resume
[18446744061.848344] leds tpacpi::bay_active: legacy class resume
[18446744061.848347] leds tpacpi::dock_batt: legacy class resume
[18446744061.848349] leds tpacpi::unknown_led: legacy class resume
[18446744061.848351] leds tpacpi::standby: legacy class resume
[18446744061.848353] leds tpacpi::dock_status1: legacy class resume
[18446744061.848355] leds tpacpi::dock_status2: legacy class resume
[18446744061.848357] leds tpacpi::unknown_led2: legacy class resume
[18446744061.848359] leds tpacpi::unknown_led3: legacy class resume
[18446744061.848361] leds tpacpi::thinkvantage: legacy class resume
[18446744061.848364] input input6: type resume
[18446744061.848370] ieee80211 phy0: legacy class resume
[18446744061.848381] rfkill rfkill1: legacy class resume
[18446744061.848397] input input7: type resume
[18446744061.848399] input input8: type resume
[18446744061.848434] drm controlD64: legacy class resume
[18446744061.848436] drm card0: legacy class resume
[18446744061.848439] i2c i2c-1: resume
[18446744061.848441] drm card0-VGA-1: legacy class resume
[18446744061.848442] i2c i2c-2: resume
[18446744061.848444] drm card0-LVDS-1: legacy class resume
[18446744061.848446] i2c i2c-3: resume
[18446744061.848448] drm card0-HDMI Type A-1: legacy class resume
[18446744061.848450] drm card0-DisplayPort-1: legacy class resume
[18446744061.848452] i2c i2c-4: resume
[18446744061.848454] backlight acpi_video0: legacy class resume
[18446744061.848457] input input9: type resume
[18446744061.848467] PM: resume of devices complete after 2504.466 msecs
[18446744061.848471] usb 1-1.5.2: completing type resume
[18446744061.848473] usb 1-1.5: completing type resume
[18446744061.848488] usb 1-1.6: completing type resume
[18446744061.848491] usb 1-1.3: completing type resume
[18446744061.848493] usb 2-1: completing type resume
[18446744061.848495] usb 1-1: completing type resume
[18446744061.848499] thinkpad_hwmon thinkpad_hwmon: completing resume
[18446744061.848501] thinkpad_acpi thinkpad_acpi: completing resume
[18446744061.848505] usb usb2: completing type resume
[18446744061.848507] usb usb1: completing type resume
[18446744061.848510] serial8250 serial8250: completing resume
[18446744061.848512] platform regulatory.0: completing resume
[18446744061.848518] i8042 i8042: completing resume
[18446744061.848610] platform microcode: completing resume
[18446744061.848661] platform pcspkr: completing resume
[18446744061.848672] iwlagn 0000:02:00.0: completing resume
[18446744061.848676] pci 0000:00:1f.6: completing resume
[18446744061.848678] i801_smbus 0000:00:1f.3: completing resume
[18446744061.848681] ahci 0000:00:1f.2: completing resume
[18446744061.848683] pci 0000:00:1f.0: completing resume
[18446744061.848686] pci 0000:00:1e.0: completing resume
[18446744061.848688] ehci_hcd 0000:00:1d.0: completing resume
[18446744061.848691] pcieport 0000:00:1c.4: completing resume
[18446744061.848693] pcieport 0000:00:1c.3: completing resume
[18446744061.848696] pcieport 0000:00:1c.0: completing resume
[18446744061.848698] HDA Intel 0000:00:1b.0: completing resume
[18446744061.848701] ehci_hcd 0000:00:1a.0: completing resume
[18446744061.848703] e1000e 0000:00:19.0: completing resume
[18446744061.848706] serial 0000:00:16.3: completing resume
[18446744061.848709] pci 0000:00:16.0: completing resume
[18446744061.848711] i915 0000:00:02.0: completing resume
[18446744061.848714] agpgart-intel 0000:00:00.0: completing resume
[18446744061.848717] pci 0000:ff:02.3: completing resume
[18446744061.848720] pci 0000:ff:02.2: completing resume
[18446744061.848722] pci 0000:ff:02.1: completing resume
[18446744061.848725] pci 0000:ff:02.0: completing resume
[18446744061.848727] pci 0000:ff:00.1: completing resume
[18446744061.848729] pci 0000:ff:00.0: completing resume
[18446744061.848732] platform dock.2: completing resume
[18446744061.848735] platform dock.1: completing resume
[18446744061.848737] platform dock.0: completing resume
[18446744061.848865] PM: Finishing wakeup.
[18446744061.848867] Restarting tasks ...=20
[18446744061.858940] usb 1-1.5: USB disconnect, address 13
[18446744061.858944] usb 1-1.5.2: USB disconnect, address 14
[18446744061.858954] PM: Removing info for No Bus:ep_81
[18446744061.858971] PM: Removing info for No Bus:ep_02
[18446744061.858982] PM: Removing info for usb:1-1.5.2:1.0
[18446744061.859006] PM: Removing info for No Bus:8:0:0:0
[18446744061.859115] PM: Removing info for No Bus:8:0:0:0
[18446744061.859127] PM: Removing info for No Bus:sg2
[18446744061.859181] PM: Removing info for scsi:8:0:0:0
[18446744061.859198] PM: Removing info for No Bus:8:0:0:0
[18446744061.859225] PM: Removing info for No Bus:sdb1
[18446744061.861765] done.
[18446744061.861771] video LNXVIDEO:00: Restoring backlight state
[18446744061.864352] PM: Removing info for No Bus:8:16
[18446744061.864405] PM: Removing info for No Bus:sdb
[18446744061.864474] PM: Removing info for scsi:target8:0:0
[18446744061.864495] PM: Removing info for No Bus:host8
[18446744061.864516] PM: Removing info for scsi:host8
[18446744061.864594] PM: Removing info for No Bus:ep_00
[18446744061.864608] PM: Removing info for usb:1-1.5.2
[18446744061.864742] PM: Removing info for No Bus:ep_81
[18446744061.864755] PM: Removing info for usb:1-1.5:1.0
[18446744061.864785] PM: Removing info for No Bus:ep_00
[18446744061.864798] PM: Removing info for usb:1-1.5
[18446744061.982195] PM: Removing info for No Bus:pan0
[18446744062.332570] usb 1-1.4: new full speed USB device using ehci_hcd an=
d address 15
[18446744062.411426] PM: Adding info for usb:1-1.4
[18446744062.411659] PM: Adding info for usb:1-1.4:1.0
[18446744062.412989] PM: Adding info for No Bus:hci0
[18446744062.413045] PM: Adding info for No Bus:rfkill6
[18446744062.413105] PM: Adding info for No Bus:ep_81
[18446744062.413124] PM: Adding info for No Bus:ep_82
[18446744062.413138] PM: Adding info for No Bus:ep_02
[18446744062.413157] PM: Adding info for usb:1-1.4:1.1
[18446744062.413217] PM: Adding info for No Bus:ep_83
[18446744062.413239] PM: Adding info for No Bus:ep_03
[18446744062.413269] PM: Adding info for usb:1-1.4:1.2
[18446744062.413348] PM: Adding info for No Bus:ep_84
[18446744062.413371] PM: Adding info for No Bus:ep_04
[18446744062.413400] PM: Adding info for usb:1-1.4:1.3
[18446744062.413477] PM: Adding info for No Bus:ep_00
[18446744062.710912] PM: Adding info for No Bus:pan0
[  104.551616] ata1: exception Emask 0x10 SAct 0x1 SErr 0x50000 action 0x1e=
 frozen
[  104.551624] ata1: irq_stat 0x00400008, PHY RDY changed
[  104.551633] ata1: SError: { PHYRdyChg CommWake }
[  104.551650] ata1: hard resetting link
[  104.732716] usb 1-1.4: USB disconnect, address 15
[  104.732742] btusb_intr_complete: hci0 urb ffff88013035e600 failed to res=
ubmit (19)
[  104.732826] btusb_bulk_complete: hci0 urb ffff88013035e180 failed to res=
ubmit (19)
[  104.732831] btusb_bulk_complete: hci0 urb ffff88013035ec00 failed to res=
ubmit (19)
[  104.732841] PM: Removing info for No Bus:ep_81
[  104.732861] PM: Removing info for No Bus:ep_82
[  104.732871] PM: Removing info for No Bus:ep_02
[  104.732881] PM: Removing info for usb:1-1.4:1.0
[  104.733096] btusb_send_frame: hci0 urb ffff8801254f8a80 submission failed
[  104.981885] PM: Removing info for No Bus:rfkill6
[  104.981952] PM: Removing info for No Bus:hci0
[  104.982045] PM: Removing info for No Bus:ep_83
[  104.982055] PM: Removing info for No Bus:ep_03
[  104.982065] PM: Removing info for usb:1-1.4:1.1
[  104.982083] PM: Removing info for No Bus:ep_84
[  104.982095] PM: Removing info for No Bus:ep_04
[  104.982105] PM: Removing info for usb:1-1.4:1.2
[  104.982129] PM: Removing info for usb:1-1.4:1.3
[  104.982148] PM: Removing info for No Bus:ep_00
[  104.982159] PM: Removing info for usb:1-1.4
[  105.424958] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[  105.426282] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succee=
ded
[  105.426290] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK=
) filtered out
[  105.426296] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filter=
ed out
[  105.466773] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) succee=
ded
[  105.466779] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZE LOCK=
) filtered out
[  105.466784] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) filter=
ed out
[  105.468887] ata1.00: configured for UDMA/100
[  105.483470] ata1.00: configured for UDMA/100
[  105.483481] ata1: EH complete
[  105.941840] PM: Syncing filesystems ... done.
[  106.024552] PM: Preparing system for mem sleep
[  106.149241] Freezing user space processes ... (elapsed 0.01 seconds) don=
e.
[  106.159560] Freezing remaining freezable tasks ... (elapsed 0.01 seconds=
) done.
[  106.170532] PM: Entering mem sleep
[  106.170630] Suspending console(s) (use no_console_suspend to debug)
[  106.170659] platform dock.0: preparing suspend
[  106.170662] platform dock.1: preparing suspend
[  106.170664] platform dock.2: preparing suspend
[  106.170667] pci 0000:ff:00.0: preparing suspend
[  106.170668] pci 0000:ff:00.1: preparing suspend
[  106.170670] pci 0000:ff:02.0: preparing suspend
[  106.170672] pci 0000:ff:02.1: preparing suspend
[  106.170674] pci 0000:ff:02.2: preparing suspend
[  106.170676] pci 0000:ff:02.3: preparing suspend
[  106.170678] agpgart-intel 0000:00:00.0: preparing suspend
[  106.170681] i915 0000:00:02.0: preparing suspend
[  106.170682] pci 0000:00:16.0: preparing suspend
[  106.170685] serial 0000:00:16.3: preparing suspend
[  106.170687] e1000e 0000:00:19.0: preparing suspend, may wakeup
[  106.170689] ehci_hcd 0000:00:1a.0: preparing suspend
[  106.170692] HDA Intel 0000:00:1b.0: preparing suspend
[  106.170694] pcieport 0000:00:1c.0: preparing suspend
[  106.170696] pcieport 0000:00:1c.3: preparing suspend
[  106.170698] pcieport 0000:00:1c.4: preparing suspend
[  106.170700] ehci_hcd 0000:00:1d.0: preparing suspend
[  106.170701] pci 0000:00:1e.0: preparing suspend
[  106.170703] pci 0000:00:1f.0: preparing suspend
[  106.170705] ahci 0000:00:1f.2: preparing suspend
[  106.170707] i801_smbus 0000:00:1f.3: preparing suspend
[  106.170709] pci 0000:00:1f.6: preparing suspend
[  106.170712] iwlagn 0000:02:00.0: preparing suspend
[  106.170719] platform pcspkr: preparing suspend
[  106.170721] platform microcode: preparing suspend
[  106.170810] i8042 i8042: preparing suspend
[  106.170819] platform regulatory.0: preparing suspend
[  106.170821] serial8250 serial8250: preparing suspend
[  106.170825] usb usb1: preparing type suspend, may wakeup
[  106.170828] usb usb2: preparing type suspend, may wakeup
[  106.170835] thinkpad_acpi thinkpad_acpi: preparing suspend
[  106.170837] thinkpad_hwmon thinkpad_hwmon: preparing suspend
[  106.170843] usb 1-1: preparing type suspend
[  106.170846] usb 2-1: preparing type suspend
[  106.170849] usb 1-1.3: preparing type suspend
[  106.170852] usb 1-1.6: preparing type suspend
[  106.170887] input input9: type suspend
[  106.170891] backlight acpi_video0: legacy class suspend
[  106.170895] i2c i2c-4: suspend
[  106.170898] drm card0-DisplayPort-1: legacy class suspend
[  106.170900] drm card0-HDMI Type A-1: legacy class suspend
[  106.170902] i2c i2c-3: suspend
[  106.170904] drm card0-LVDS-1: legacy class suspend
[  106.170905] i2c i2c-2: suspend
[  106.170907] drm card0-VGA-1: legacy class suspend
[  106.170909] i2c i2c-1: suspend
[  106.170911] drm card0: legacy class suspend
[  106.170913] drm controlD64: legacy class suspend
[  106.170959] input input8: type suspend
[  106.170961] input input7: type suspend
[  106.170972] rfkill rfkill1: legacy class suspend
[  106.170975] ieee80211 phy0: legacy class suspend
[  106.171065] usb 1-1.6: type suspend
[  106.171074] usb 1-1.3: type suspend
[  106.182592] usb 2-1: type suspend
[  106.182597] input input6: type suspend
[  106.182604] leds tpacpi::thinkvantage: legacy class suspend
[  106.182608] leds tpacpi::unknown_led3: legacy class suspend
[  106.182612] leds tpacpi::unknown_led2: legacy class suspend
[  106.182616] leds tpacpi::dock_status2: legacy class suspend
[  106.182620] leds tpacpi::dock_status1: legacy class suspend
[  106.182624] leds tpacpi::standby: legacy class suspend
[  106.182629] leds tpacpi::unknown_led: legacy class suspend
[  106.182633] leds tpacpi::dock_batt: legacy class suspend
[  106.182637] leds tpacpi::bay_active: legacy class suspend
[  106.182641] leds tpacpi::dock_active: legacy class suspend
[  106.182645] leds tpacpi:green:batt: legacy class suspend
[  106.182649] usb 1-1: type suspend
[  106.182653] leds tpacpi:orange:batt: legacy class suspend
[  106.182657] leds tpacpi::power: legacy class suspend
[  106.182661] leds tpacpi::thinklight: legacy class suspend
[  106.182665] rfkill rfkill0: legacy class suspend
[  106.182670] thinkpad_hwmon thinkpad_hwmon: suspend
[  106.182677] thinkpad_acpi thinkpad_acpi: suspend
[  106.182704] usb usb2: type suspend, may wakeup
[  106.182707] i2c i2c-0: suspend
[  106.182712] serial8250 serial8250: suspend
[  106.182715] platform regulatory.0: suspend
[  106.182719] psmouse serio2: suspend
[  106.182721] usb usb1: type suspend, may wakeup
[  106.355503] input input4: type suspend
[  106.355522] input input3: type suspend
[  106.355528] sd 0:0:0:0: legacy suspend
[  106.355531] psmouse serio1: suspend
[  106.355537] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[  106.382651] sd 0:0:0:0: [sda] Stopping disk
[  106.407429] atkbd serio0: suspend
[  106.408048] i8042 i8042: suspend
[  106.408826] scsi host5: legacy suspend
[  106.408830] scsi host4: legacy suspend
[  106.408833] scsi host3: legacy suspend
[  106.408835] scsi host2: legacy suspend
[  106.408837] scsi host1: legacy suspend
[  106.408909] input input2: type suspend
[  106.408912] input input1: type suspend
[  106.408914] input input0: type suspend
[  106.408918] platform microcode: suspend
[  106.408920] platform pcspkr: suspend
[  106.408925] system 00:0c: legacy suspend
[  106.408927] ACPI handle has no context!
[  106.408931] tpm_tis 00:0b: legacy suspend
[  106.599818] i8042 aux 00:0a: legacy suspend
[  106.599830] i8042 kbd 00:09: legacy suspend
[  106.599841] rtc_cmos 00:08: legacy suspend, may wakeup
[  106.599855] pnp 00:07: legacy suspend
[  106.599857] pnp 00:06: legacy suspend
[  106.599860] pnp 00:05: legacy suspend
[  106.599863] pnp 00:04: legacy suspend
[  106.599866] system 00:03: legacy suspend
[  106.599877] pnp 00:02: legacy suspend
[  106.599879] pnp 00:01: legacy suspend
[  106.599880] system 00:00: legacy suspend
[  106.599956] iwlagn 0000:02:00.0: suspend
[  106.599974] platform dock.2: suspend
[  106.599976] platform dock.1: suspend
[  106.599978] platform dock.0: suspend
[  106.599980] button LNXPWRBN:00: legacy suspend
[  106.599983] thermal LNXTHERM:01: legacy suspend
[  106.599985] acpi LNXTHERM:00: legacy suspend
[  106.599987] wmi PNP0C14:00: legacy suspend
[  106.599989] acpi PNP0C02:01: legacy suspend
[  106.599991] acpi device:32: legacy suspend
[  106.599993] acpi device:31: legacy suspend
[  106.599994] acpi device:2f: legacy suspend
[  106.599996] acpi device:2e: legacy suspend
[  106.599998] acpi device:2d: legacy suspend
[  106.600000] acpi device:2c: legacy suspend
[  106.600002] acpi device:2b: legacy suspend
[  106.600003] acpi device:2a: legacy suspend
[  106.600005] acpi device:29: legacy suspend
[  106.600007] acpi device:28: legacy suspend
[  106.600009] acpi device:27: legacy suspend
[  106.600011] acpi device:26: legacy suspend
[  106.600012] acpi device:25: legacy suspend
[  106.600014] acpi device:24: legacy suspend
[  106.600016] acpi device:23: legacy suspend
[  106.600018] acpi device:22: legacy suspend
[  106.600019] acpi device:21: legacy suspend
[  106.600022] acpi device:20: legacy suspend
[  106.600024] acpi device:1f: legacy suspend
[  106.600026] acpi device:1e: legacy suspend
[  106.600027] acpi device:1d: legacy suspend
[  106.600029] acpi device:1c: legacy suspend
[  106.600031] acpi device:1b: legacy suspend
[  106.600033] acpi device:1a: legacy suspend
[  106.600034] acpi device:19: legacy suspend
[  106.600036] acpi device:18: legacy suspend
[  106.600038] acpi device:17: legacy suspend
[  106.600040] acpi device:16: legacy suspend
[  106.600041] acpi device:15: legacy suspend
[  106.600043] acpi device:14: legacy suspend
[  106.600045] acpi device:13: legacy suspend
[  106.600047] acpi device:12: legacy suspend
[  106.600049] acpi device:11: legacy suspend
[  106.600050] acpi device:10: legacy suspend
[  106.600052] acpi device:0f: legacy suspend
[  106.600054] acpi device:0e: legacy suspend
[  106.600056] acpi device:0d: legacy suspend
[  106.600057] acpi device:0c: legacy suspend
[  106.600059] acpi device:0b: legacy suspend
[  106.600061] acpi LNXVIDEO:01: legacy suspend
[  106.600063] acpi device:0a: legacy suspend
[  106.600065] thinkpad_hotkey IBM0068:00: legacy suspend
[  106.600067] ac ACPI0003:00: legacy suspend
[  106.600070] battery PNP0C0A:00: legacy suspend
[  106.600072] power LNXPOWER:00: legacy suspend
[  106.600074] ec PNP0C09:00: legacy suspend
[  106.600080] acpi SMO1200:00: legacy suspend
[  106.600082] acpi LEN0018:00: legacy suspend
[  106.600085] acpi PNP0303:00: legacy suspend
[  106.600087] pci 0000:00:1f.6: suspend
[  106.600089] acpi PNP0B00:00: legacy suspend
[  106.600092] i801_smbus 0000:00:1f.3: suspend
[  106.600093] acpi PNP0C04:00: legacy suspend
[  106.600095] acpi PNP0800:00: legacy suspend
[  106.600097] acpi PNP0200:00: legacy suspend
[  106.600099] acpi PNP0103:00: legacy suspend
[  106.600101] acpi PNP0100:00: legacy suspend
[  106.600102] acpi PNP0000:00: legacy suspend
[  106.600104] acpi PNP0C02:00: legacy suspend
[  106.600107] acpi device:09: legacy suspend
[  106.600108] acpi device:08: legacy suspend
[  106.600110] acpi device:07: legacy suspend
[  106.600112] acpi device:06: legacy suspend
[  106.600113] acpi device:05: legacy suspend
[  106.600115] acpi device:04: legacy suspend
[  106.600117] acpi device:03: legacy suspend
[  106.600118] acpi device:02: legacy suspend
[  106.600120] acpi device:01: legacy suspend
[  106.600123] video LNXVIDEO:00: legacy suspend
[  106.600127] pci_root PNP0A08:00: legacy suspend
[  106.600129] pci 0000:00:1f.0: suspend
[  106.600131] acpi device:00: legacy suspend
[  106.600133] pci 0000:00:1e.0: suspend
[  106.600135] pci_root PNP0A03:00: legacy suspend
[  106.600136] ehci_hcd 0000:00:1d.0: suspend
[  106.600138] button PNP0C0E:00: legacy suspend
[  106.600140] button PNP0C0D:00: legacy suspend
[  106.600141] acpi PNP0C01:00: legacy suspend
[  106.600143] pci_link PNP0C0F:07: legacy suspend
[  106.600145] pci_link PNP0C0F:06: legacy suspend
[  106.600147] pci_link PNP0C0F:05: legacy suspend
[  106.600149] pci_link PNP0C0F:04: legacy suspend
[  106.600150] pci_link PNP0C0F:03: legacy suspend
[  106.600152] ehci_hcd 0000:00:1d.0: PCI INT D disabled
[  106.600154] pci_link PNP0C0F:02: legacy suspend
[  106.600156] pci_link PNP0C0F:01: legacy suspend
[  106.600158] pci_link PNP0C0F:00: legacy suspend
[  106.600160] pcieport 0000:00:1c.3: suspend
[  106.600163] acpi LNXSYBUS:00: legacy suspend
[  106.600165] pcieport 0000:00:1c.0: suspend
[  106.600167] processor LNXCPU:07: legacy suspend
[  106.600168] HDA Intel 0000:00:1b.0: suspend
[  106.600171] processor LNXCPU:06: legacy suspend
[  106.600173] processor LNXCPU:05: legacy suspend
[  106.600175] processor LNXCPU:04: legacy suspend
[  106.600176] processor LNXCPU:03: legacy suspend
[  106.600178] processor LNXCPU:02: legacy suspend
[  106.600180] processor LNXCPU:01: legacy suspend
[  106.600182] processor LNXCPU:00: legacy suspend
[  106.600184] acpi LNXSYSTM:00: legacy suspend
[  106.600189] HDA Intel 0000:00:1b.0: PCI INT B disabled
[  106.600251] ehci_hcd 0000:00:1a.0: suspend
[  106.600264] ehci_hcd 0000:00:1a.0: PCI INT D disabled
[  106.600268] e1000e 0000:00:19.0: suspend, may wakeup
[  106.600280] serial 0000:00:16.3: suspend
[  106.600318] ACPI handle has no context!
[  106.600327] pci 0000:00:16.0: suspend
[  106.600332] i915 0000:00:02.0: suspend
[  106.600562] agpgart-intel 0000:00:00.0: suspend
[  106.600572] pci 0000:ff:02.3: suspend
[  106.600575] pci 0000:ff:02.2: suspend
[  106.600578] pci 0000:ff:02.1: suspend
[  106.600581] pci 0000:ff:02.0: suspend
[  106.600583] pci 0000:ff:00.1: suspend
[  106.600586] pci 0000:ff:00.0: suspend
[  106.611081] pcieport 0000:00:1c.4: suspend
[  106.615101] i915 0000:00:02.0: power state changed by ACPI to D3
[  106.763249] scsi target0:0:0: legacy suspend
[  106.763254] scsi host0: legacy suspend
[  106.763261] ahci 0000:00:1f.2: suspend
[  106.780937] e1000e 0000:00:19.0: PME# enabled
[  106.780948] e1000e 0000:00:19.0: wake-up capability enabled by ACPI
[  106.828270] PM: suspend of devices complete after 658.640 msecs
[  106.828308] input input9: LATE type suspend
[  106.828311] i2c i2c-4: LATE suspend
[  106.828313] i2c i2c-3: LATE suspend
[  106.828315] i2c i2c-2: LATE suspend
[  106.828317] i2c i2c-1: LATE suspend
[  106.828323] input input8: LATE type suspend
[  106.828326] input input7: LATE type suspend
[  106.828328] usb 1-1.6: LATE type suspend
[  106.828330] usb 1-1.3: LATE type suspend
[  106.828333] usb 2-1: LATE type suspend
[  106.828335] usb 1-1: LATE type suspend
[  106.828337] input input6: LATE type suspend
[  106.828341] thinkpad_hwmon thinkpad_hwmon: LATE suspend
[  106.828343] thinkpad_acpi thinkpad_acpi: LATE suspend
[  106.828346] usb usb2: LATE type suspend, may wakeup
[  106.828349] usb usb1: LATE type suspend, may wakeup
[  106.828351] i2c i2c-0: LATE suspend
[  106.828354] serial8250 serial8250: LATE suspend
[  106.828356] platform regulatory.0: LATE suspend
[  106.828359] psmouse serio2: LATE suspend
[  106.828361] input input4: LATE type suspend
[  106.828364] input input3: LATE type suspend
[  106.828367] psmouse serio1: LATE suspend
[  106.828369] atkbd serio0: LATE suspend
[  106.828371] i8042 i8042: LATE suspend
[  106.828387] input input2: LATE type suspend
[  106.828389] input input1: LATE type suspend
[  106.828392] input input0: LATE type suspend
[  106.828394] platform microcode: LATE suspend
[  106.828396] platform pcspkr: LATE suspend
[  106.828399] iwlagn 0000:02:00.0: LATE suspend
[  106.828402] pci 0000:00:1f.6: LATE suspend
[  106.828435] i801_smbus 0000:00:1f.3: LATE suspend
[  106.828438] ahci 0000:00:1f.2: LATE suspend
[  106.828440] pci 0000:00:1f.0: LATE suspend
[  106.828470] pci 0000:00:1e.0: LATE suspend
[  106.828499] ehci_hcd 0000:00:1d.0: LATE suspend
[  106.841303] ehci_hcd 0000:00:1d.0: power state changed by ACPI to D3
[  106.841308] pcieport 0000:00:1c.4: LATE suspend
[  106.841359] pcieport 0000:00:1c.3: LATE suspend
[  106.841409] pcieport 0000:00:1c.0: LATE suspend
[  106.841458] HDA Intel 0000:00:1b.0: LATE suspend
[  106.841461] ehci_hcd 0000:00:1a.0: LATE suspend
[  106.859250] ehci_hcd 0000:00:1a.0: power state changed by ACPI to D3
[  106.859255] e1000e 0000:00:19.0: LATE suspend, may wakeup
[  106.859258] serial 0000:00:16.3: LATE suspend
[  106.859260] pci 0000:00:16.0: LATE suspend
[  106.859294] i915 0000:00:02.0: LATE suspend
[  106.859296] agpgart-intel 0000:00:00.0: LATE suspend
[  106.859307] pci 0000:ff:02.3: LATE suspend
[  106.859316] pci 0000:ff:02.2: LATE suspend
[  106.859324] pci 0000:ff:02.1: LATE suspend
[  106.859333] pci 0000:ff:02.0: LATE suspend
[  106.859341] pci 0000:ff:00.1: LATE suspend
[  106.859349] pci 0000:ff:00.0: LATE suspend
[  106.859357] platform dock.2: LATE suspend
[  106.859360] platform dock.1: LATE suspend
[  106.859362] platform dock.0: LATE suspend
[  106.859368] PM: late suspend of devices complete after 31.153 msecs
[  106.869233] ACPI: Preparing to enter system sleep state S3
[  106.907202] PM: Saving platform NVS memory
[  107.040569] Disabling non-boot CPUs ...
[  107.053051] CPU 1 is now offline
[  107.169646] CPU 2 is now offline
[  107.186758] CPU 3 is now offline
[  107.186759] SMP alternatives: switching to UP code
[  107.190429] Extended CMOS year: 2000
[18446744058.743440] Back to C!
[18446744058.743443] PM: Restoring platform NVS memory
[18446744058.880804] Extended CMOS year: 2000
[18446744058.880822] Enabling non-boot CPUs ...
[18446744058.881017] SMP alternatives: switching to SMP code
[18446744058.884007] Booting Node 0 Processor 1 APIC 0x1
[18446744058.983922] CPU1 is up
[18446744058.984055] Booting Node 0 Processor 2 APIC 0x4
[18446744059.090843] CPU2 is up
[18446744059.090973] Booting Node 0 Processor 3 APIC 0x5
[18446744059.197657] CPU3 is up
[18446744059.199131] ACPI: Waking up from system sleep state S3
[18446744059.275438] platform dock.0: EARLY resume
[18446744059.275442] platform dock.1: EARLY resume
[18446744059.275444] platform dock.2: EARLY resume
[18446744059.275447] pci 0000:ff:00.0: EARLY resume
[18446744059.275461] pci 0000:ff:00.1: EARLY resume
[18446744059.275471] pci 0000:ff:02.0: EARLY resume
[18446744059.275481] pci 0000:ff:02.1: EARLY resume
[18446744059.275490] pci 0000:ff:02.2: EARLY resume
[18446744059.275500] pci 0000:ff:02.3: EARLY resume
[18446744059.275510] agpgart-intel 0000:00:00.0: EARLY resume
[18446744059.275525] i915 0000:00:02.0: EARLY resume
[18446744059.275539] i915 0000:00:02.0: restoring config space at offset 0x=
1 (was 0x900007, writing 0x900407)
[18446744059.275553] pci 0000:00:16.0: EARLY resume
[18446744059.275596] serial 0000:00:16.3: EARLY resume
[18446744059.275640] e1000e 0000:00:19.0: EARLY resume
[18446744059.275690] ehci_hcd 0000:00:1a.0: EARLY resume
[18446744059.275708] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.275728] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728000)
[18446744059.275738] ehci_hcd 0000:00:1a.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.286348] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.288362] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.288369] HDA Intel 0000:00:1b.0: EARLY resume
[18446744059.288421] pcieport 0000:00:1c.0: EARLY resume
[18446744059.288463] pcieport 0000:00:1c.0: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.288497] pcieport 0000:00:1c.3: EARLY resume
[18446744059.288538] pcieport 0000:00:1c.3: restoring config space at offse=
t 0x1 (was 0x100107, writing 0x100507)
[18446744059.288572] pcieport 0000:00:1c.4: EARLY resume
[18446744059.288594] pcieport 0000:00:1c.4: restoring config space at offse=
t 0xf (was 0x100, writing 0x4010b)
[18446744059.288607] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x9 (was 0x10001, writing 0x1fff1)
[18446744059.288614] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x8 (was 0x0, writing 0xf240f240)
[18446744059.288621] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x7 (was 0x0, writing 0xf0)
[18446744059.288631] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x3 (was 0x810000, writing 0x810010)
[18446744059.288639] pcieport 0000:00:1c.4: restoring config space at offse=
t 0x1 (was 0x100000, writing 0x100507)
[18446744059.288672] ehci_hcd 0000:00:1d.0: EARLY resume
[18446744059.288690] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0xf (was 0x400, writing 0x40b)
[18446744059.288710] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x4 (was 0x0, writing 0xf2728400)
[18446744059.288720] ehci_hcd 0000:00:1d.0: restoring config space at offse=
t 0x1 (was 0x2900000, writing 0x2900102)
[18446744059.290356] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.292352] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.292358] pci 0000:00:1e.0: EARLY resume
[18446744059.292396] pci 0000:00:1f.0: EARLY resume
[18446744059.292434] ahci 0000:00:1f.2: EARLY resume
[18446744059.292472] ahci 0000:00:1f.2: restoring config space at offset 0x=
1 (was 0x2b00007, writing 0x2b00407)
[18446744059.292506] i801_smbus 0000:00:1f.3: EARLY resume
[18446744059.292536] pci 0000:00:1f.6: EARLY resume
[18446744059.292551] pci 0000:00:1f.6: restoring config space at offset 0xf=
 (was 0x400, writing 0x40b)
[18446744059.292575] pci 0000:00:1f.6: restoring config space at offset 0x1=
 (was 0x100000, writing 0x100002)
[18446744059.292591] iwlagn 0000:02:00.0: EARLY resume
[18446744059.292665] iwlagn 0000:02:00.0: restoring config space at offset =
0x1 (was 0x100106, writing 0x100506)
[18446744059.292725] platform pcspkr: EARLY resume
[18446744059.292727] platform microcode: EARLY resume
[18446744059.292731] input input0: EARLY type resume
[18446744059.292734] input input1: EARLY type resume
[18446744059.292736] input input2: EARLY type resume
[18446744059.292786] i8042 i8042: EARLY resume
[18446744059.292789] atkbd serio0: EARLY resume
[18446744059.292791] psmouse serio1: EARLY resume
[18446744059.292794] input input3: EARLY type resume
[18446744059.292798] input input4: EARLY type resume
[18446744059.292801] psmouse serio2: EARLY resume
[18446744059.292804] platform regulatory.0: EARLY resume
[18446744059.292807] serial8250 serial8250: EARLY resume
[18446744059.292811] i2c i2c-0: EARLY resume
[18446744059.292813] usb usb1: EARLY type resume
[18446744059.292816] usb usb2: EARLY type resume
[18446744059.292822] thinkpad_acpi thinkpad_acpi: EARLY resume
[18446744059.292825] thinkpad_hwmon thinkpad_hwmon: EARLY resume
[18446744059.292829] input input6: EARLY type resume
[18446744059.292832] usb 1-1: EARLY type resume
[18446744059.292835] usb 2-1: EARLY type resume
[18446744059.292838] usb 1-1.3: EARLY type resume
[18446744059.292841] usb 1-1.6: EARLY type resume
[18446744059.292845] input input7: EARLY type resume
[18446744059.292847] input input8: EARLY type resume
[18446744059.292863] i2c i2c-1: EARLY resume
[18446744059.292866] i2c i2c-2: EARLY resume
[18446744059.292868] i2c i2c-3: EARLY resume
[18446744059.292871] i2c i2c-4: EARLY resume
[18446744059.292873] input input9: EARLY type resume
[18446744059.292878] PM: early resume of devices complete after 17.484 msecs
[18446744059.292937] pci 0000:ff:00.0: resume
[18446744059.292946] pci 0000:ff:00.1: resume
[18446744059.292959] pci 0000:ff:02.0: resume
[18446744059.292970] pci 0000:ff:02.1: resume
[18446744059.292981] pci 0000:ff:02.2: resume
[18446744059.292991] pci 0000:ff:02.3: resume
[18446744059.293011] agpgart-intel 0000:00:00.0: resume
[18446744059.293024] i915 0000:00:02.0: resume
[18446744059.293032] pci 0000:00:16.0: resume
[18446744059.293041] serial 0000:00:16.3: resume
[18446744059.293048] e1000e 0000:00:19.0: resume
[18446744059.293056] ehci_hcd 0000:00:1a.0: resume
[18446744059.293061] HDA Intel 0000:00:1b.0: resume
[18446744059.293065] pcieport 0000:00:1c.0: resume
[18446744059.293071] pcieport 0000:00:1c.3: resume
[18446744059.293077] pcieport 0000:00:1c.4: resume
[18446744059.293089] ehci_hcd 0000:00:1d.0: resume
[18446744059.293101] pci 0000:00:1e.0: resume
[18446744059.293114] e1000e 0000:00:19.0: wake-up capability disabled by AC=
PI
[18446744059.293117] pci 0000:00:1f.0: resume
[18446744059.293119] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.293122] e1000e 0000:00:19.0: PME# disabled
[18446744059.293129] ahci 0000:00:1f.2: resume
[18446744059.293146] i801_smbus 0000:00:1f.3: resume
[18446744059.293158] pci 0000:00:1f.6: resume
[18446744059.293164] pci 0000:00:1e.0: setting latency timer to 64
[18446744059.293169] iwlagn 0000:02:00.0: resume
[18446744059.293204] HDA Intel 0000:00:1b.0: PCI INT B -> GSI 17 (level, lo=
w) -> IRQ 17
[18446744059.293214] HDA Intel 0000:00:1b.0: setting latency timer to 64
[18446744059.293292] HDA Intel 0000:00:1b.0: irq 44 for MSI/MSI-X
[18446744059.293294] e1000e 0000:00:19.0: irq 45 for MSI/MSI-X
[18446744059.293401] ahci 0000:00:1f.2: setting latency timer to 64
[18446744059.293543] scsi host0: legacy resume
[18446744059.293584] scsi host1: legacy resume
[18446744059.293605] scsi host2: legacy resume
[18446744059.293666] i915 0000:00:02.0: power state changed by ACPI to D0
[18446744059.293672] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.293679] i915 0000:00:02.0: setting latency timer to 64
[18446744059.293753] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.293801] scsi host3: legacy resume
[18446744059.293822] scsi host4: legacy resume
[18446744059.293842] scsi host5: legacy resume
[18446744059.293862] scsi target0:0:0: legacy resume
[18446744059.293874] sd 0:0:0:0: legacy resume
[18446744059.293880] sd 0:0:0:0: [sda] Starting disk
[18446744059.293958] ehci_hcd 0000:00:1d.0: power state changed by ACPI to =
D0
[18446744059.293965] ehci_hcd 0000:00:1d.0: PCI INT D -> GSI 19 (level, low=
) -> IRQ 19
[18446744059.293972] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[18446744059.294045] usb usb2: type resume
[18446744059.294153] ehci_hcd 0000:00:1a.0: power state changed by ACPI to =
D0
[18446744059.294161] ehci_hcd 0000:00:1a.0: PCI INT D -> GSI 23 (level, low=
) -> IRQ 23
[18446744059.294168] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[18446744059.294194] usb usb1: type resume
[18446744059.294270] acpi LNXSYSTM:00: legacy resume
[18446744059.294272] processor LNXCPU:00: legacy resume
[18446744059.294276] processor LNXCPU:01: legacy resume
[18446744059.294283] processor LNXCPU:02: legacy resume
[18446744059.294285] processor LNXCPU:03: legacy resume
[18446744059.294287] processor LNXCPU:04: legacy resume
[18446744059.294289] processor LNXCPU:05: legacy resume
[18446744059.294291] processor LNXCPU:06: legacy resume
[18446744059.294293] processor LNXCPU:07: legacy resume
[18446744059.294295] acpi LNXSYBUS:00: legacy resume
[18446744059.294297] pci_link PNP0C0F:00: legacy resume
[18446744059.294299] pci_link PNP0C0F:01: legacy resume
[18446744059.294301] pci_link PNP0C0F:02: legacy resume
[18446744059.294304] pci_link PNP0C0F:03: legacy resume
[18446744059.294306] pci_link PNP0C0F:04: legacy resume
[18446744059.294308] pci_link PNP0C0F:05: legacy resume
[18446744059.294310] pci_link PNP0C0F:06: legacy resume
[18446744059.294312] pci_link PNP0C0F:07: legacy resume
[18446744059.294315] acpi PNP0C01:00: legacy resume
[18446744059.294317] button PNP0C0D:00: legacy resume
[18446744059.294670] button PNP0C0E:00: legacy resume
[18446744059.294673] pci_root PNP0A03:00: legacy resume
[18446744059.294676] acpi device:00: legacy resume
[18446744059.294678] pci_root PNP0A08:00: legacy resume
[18446744059.294680] video LNXVIDEO:00: legacy resume
[18446744059.294683] acpi device:01: legacy resume
[18446744059.294685] acpi device:02: legacy resume
[18446744059.294687] acpi device:03: legacy resume
[18446744059.294689] acpi device:04: legacy resume
[18446744059.294691] acpi device:05: legacy resume
[18446744059.294693] acpi device:06: legacy resume
[18446744059.294695] acpi device:07: legacy resume
[18446744059.294696] acpi device:08: legacy resume
[18446744059.294699] acpi device:09: legacy resume
[18446744059.294701] acpi PNP0C02:00: legacy resume
[18446744059.294703] acpi PNP0000:00: legacy resume
[18446744059.294705] acpi PNP0100:00: legacy resume
[18446744059.294707] acpi PNP0103:00: legacy resume
[18446744059.294709] acpi PNP0200:00: legacy resume
[18446744059.294711] acpi PNP0800:00: legacy resume
[18446744059.294714] acpi PNP0C04:00: legacy resume
[18446744059.294716] acpi PNP0B00:00: legacy resume
[18446744059.294718] acpi PNP0303:00: legacy resume
[18446744059.294720] acpi LEN0018:00: legacy resume
[18446744059.294722] acpi SMO1200:00: legacy resume
[18446744059.294724] ec PNP0C09:00: legacy resume
[18446744059.294731] power LNXPOWER:00: legacy resume
[18446744059.294908] battery PNP0C0A:00: legacy resume
[18446744059.309473] ac ACPI0003:00: legacy resume
[18446744059.309653] thinkpad_hotkey IBM0068:00: legacy resume
[18446744059.309655] acpi device:0a: legacy resume
[18446744059.309657] acpi LNXVIDEO:01: legacy resume
[18446744059.309659] acpi device:0b: legacy resume
[18446744059.309660] acpi device:0c: legacy resume
[18446744059.309662] acpi device:0d: legacy resume
[18446744059.309664] acpi device:0e: legacy resume
[18446744059.309665] acpi device:0f: legacy resume
[18446744059.309667] acpi device:10: legacy resume
[18446744059.309668] acpi device:11: legacy resume
[18446744059.309670] acpi device:12: legacy resume
[18446744059.309672] acpi device:13: legacy resume
[18446744059.309673] acpi device:14: legacy resume
[18446744059.309675] acpi device:15: legacy resume
[18446744059.309676] acpi device:16: legacy resume
[18446744059.309678] acpi device:17: legacy resume
[18446744059.309680] acpi device:18: legacy resume
[18446744059.309681] acpi device:19: legacy resume
[18446744059.309683] acpi device:1a: legacy resume
[18446744059.309685] acpi device:1b: legacy resume
[18446744059.309686] acpi device:1c: legacy resume
[18446744059.309688] acpi device:1d: legacy resume
[18446744059.309690] acpi device:1e: legacy resume
[18446744059.309692] acpi device:1f: legacy resume
[18446744059.309693] acpi device:20: legacy resume
[18446744059.309695] acpi device:21: legacy resume
[18446744059.309697] acpi device:22: legacy resume
[18446744059.309698] acpi device:23: legacy resume
[18446744059.309700] acpi device:24: legacy resume
[18446744059.309702] acpi device:25: legacy resume
[18446744059.309703] acpi device:26: legacy resume
[18446744059.309705] acpi device:27: legacy resume
[18446744059.309706] acpi device:28: legacy resume
[18446744059.309708] acpi device:29: legacy resume
[18446744059.309710] acpi device:2a: legacy resume
[18446744059.309711] acpi device:2b: legacy resume
[18446744059.309713] acpi device:2c: legacy resume
[18446744059.309715] acpi device:2d: legacy resume
[18446744059.309716] acpi device:2e: legacy resume
[18446744059.309718] acpi device:2f: legacy resume
[18446744059.309720] acpi device:31: legacy resume
[18446744059.309721] acpi device:32: legacy resume
[18446744059.309723] acpi PNP0C02:01: legacy resume
[18446744059.309725] wmi PNP0C14:00: legacy resume
[18446744059.309727] acpi LNXTHERM:00: legacy resume
[18446744059.309729] thermal LNXTHERM:01: legacy resume
[18446744059.310260] button LNXPWRBN:00: legacy resume
[18446744059.310262] platform dock.0: resume
[18446744059.310264] platform dock.1: resume
[18446744059.310265] platform dock.2: resume
[18446744059.310271] system 00:00: legacy resume
[18446744059.310274] pnp 00:01: legacy resume
[18446744059.310276] pnp 00:02: legacy resume
[18446744059.310277] system 00:03: legacy resume
[18446744059.310280] pnp 00:04: legacy resume
[18446744059.310281] pnp 00:05: legacy resume
[18446744059.310283] pnp 00:06: legacy resume
[18446744059.310285] pnp 00:07: legacy resume
[18446744059.310287] rtc_cmos 00:08: legacy resume
[18446744059.310290] i8042 kbd 00:09: legacy resume
[18446744059.310292] i8042 aux 00:0a: legacy resume
[18446744059.310295] tpm_tis 00:0b: legacy resume
[18446744059.310297] system 00:0c: legacy resume
[18446744059.310302] platform pcspkr: resume
[18446744059.310303] platform microcode: resume
[18446744059.310306] input input0: type resume
[18446744059.310308] input input1: type resume
[18446744059.310310] input input2: type resume
[18446744059.310397] i8042 i8042: resume
[18446744059.311218] atkbd serio0: resume
[18446744059.311222] psmouse serio1: resume
[18446744059.311226] input input3: type resume
[18446744059.335237] usb 1-1: type resume
[18446744059.335250] usb 2-1: type resume
[18446744059.436024] usb 1-1.6: type resume
[18446744059.436031] usb 1-1.3: type resume
[18446744059.509048] usb 1-1.6: reset high speed USB device using ehci_hcd =
and address 6
[18446744059.599749] ata2: SATA link down (SStatus 0 SControl 300)
[18446744059.600630] ata5: SATA link down (SStatus 0 SControl 300)
[18446744059.602591] ata6: SATA link down (SStatus 0 SControl 300)
[18446744059.670630] usb 1-1.3: reset full speed USB device using ehci_hcd =
and address 3
[18446744061.837385] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[18446744061.839760] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.839766] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.839771] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.844603] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 (SET FEATURES) =
succeeded
[18446744061.844610] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 (SECURITY FREEZ=
E LOCK) filtered out
[18446744061.844616] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 (SET FEATURES) =
filtered out
[18446744061.846675] ata1.00: configured for UDMA/100
[18446744061.861973] ata1.00: configured for UDMA/100
[18446744061.861978] ata1: EH complete
[18446744061.884789] input input4: type resume
[18446744061.884795] psmouse serio2: resume
[18446744061.884804] platform regulatory.0: resume
[18446744061.884808] serial8250 serial8250: resume
[18446744061.884817] i2c i2c-0: resume
[18446744061.884841] thinkpad_acpi thinkpad_acpi: resume
[18446744061.888026] thinkpad_hwmon thinkpad_hwmon: resume
[18446744061.888076] rfkill rfkill0: legacy class resume
[18446744061.888080] leds tpacpi::thinklight: legacy class resume
[18446744061.888083] leds tpacpi::power: legacy class resume
[18446744061.888086] leds tpacpi:orange:batt: legacy class resume
[18446744061.888089] leds tpacpi:green:batt: legacy class resume
[18446744061.888092] leds tpacpi::dock_active: legacy class resume
[18446744061.888095] leds tpacpi::bay_active: legacy class resume
[18446744061.888097] leds tpacpi::dock_batt: legacy class resume
[18446744061.888100] leds tpacpi::unknown_led: legacy class resume
[18446744061.888103] leds tpacpi::standby: legacy class resume
[18446744061.888106] leds tpacpi::dock_status1: legacy class resume
[18446744061.888108] leds tpacpi::dock_status2: legacy class resume
[18446744061.888111] leds tpacpi::unknown_led2: legacy class resume
[18446744061.888113] leds tpacpi::unknown_led3: legacy class resume
[18446744061.888116] leds tpacpi::thinkvantage: legacy class resume
[18446744061.888119] input input6: type resume
[18446744061.888126] ieee80211 phy0: legacy class resume
[18446744061.888137] rfkill rfkill1: legacy class resume
[18446744061.888159] input input7: type resume
[18446744061.888162] input input8: type resume
[18446744061.888216] drm controlD64: legacy class resume
[18446744061.888219] drm card0: legacy class resume
[18446744061.888222] i2c i2c-1: resume
[18446744061.888225] drm card0-VGA-1: legacy class resume
[18446744061.888227] i2c i2c-2: resume
[18446744061.888229] drm card0-LVDS-1: legacy class resume
[18446744061.888232] i2c i2c-3: resume
[18446744061.888234] drm card0-HDMI Type A-1: legacy class resume
[18446744061.888237] drm card0-DisplayPort-1: legacy class resume
[18446744061.888239] i2c i2c-4: resume
[18446744061.888243] backlight acpi_video0: legacy class resume
[18446744061.888248] input input9: type resume
[18446744061.888253] PM: resume of devices complete after 2600.291 msecs
[18446744061.888269] usb 1-1.6: completing type resume
[18446744061.888271] usb 1-1.3: completing type resume
[18446744061.888274] usb 2-1: completing type resume
[18446744061.888276] usb 1-1: completing type resume
[18446744061.888280] thinkpad_hwmon thinkpad_hwmon: completing resume
[18446744061.888282] thinkpad_acpi thinkpad_acpi: completing resume
[18446744061.888286] usb usb2: completing type resume
[18446744061.888289] usb usb1: completing type resume
[18446744061.888291] serial8250 serial8250: completing resume
[18446744061.888293] platform regulatory.0: completing resume
[18446744061.888301] i8042 i8042: completing resume
[18446744061.888393] platform microcode: completing resume
[18446744061.888395] platform pcspkr: completing resume
[18446744061.888402] iwlagn 0000:02:00.0: completing resume
[18446744061.888405] pci 0000:00:1f.6: completing resume
[18446744061.888407] i801_smbus 0000:00:1f.3: completing resume
[18446744061.888409] ahci 0000:00:1f.2: completing resume
[18446744061.888411] pci 0000:00:1f.0: completing resume
[18446744061.888413] pci 0000:00:1e.0: completing resume
[18446744061.888414] ehci_hcd 0000:00:1d.0: completing resume
[18446744061.888417] pcieport 0000:00:1c.4: completing resume
[18446744061.888419] pcieport 0000:00:1c.3: completing resume
[18446744061.888421] pcieport 0000:00:1c.0: completing resume
[18446744061.888423] HDA Intel 0000:00:1b.0: completing resume
[18446744061.888425] ehci_hcd 0000:00:1a.0: completing resume
[18446744061.888428] e1000e 0000:00:19.0: completing resume
[18446744061.888430] serial 0000:00:16.3: completing resume
[18446744061.888432] pci 0000:00:16.0: completing resume
[18446744061.888434] i915 0000:00:02.0: completing resume
[18446744061.888436] agpgart-intel 0000:00:00.0: completing resume
[18446744061.888439] pci 0000:ff:02.3: completing resume
[18446744061.888441] pci 0000:ff:02.2: completing resume
[18446744061.888442] pci 0000:ff:02.1: completing resume
[18446744061.888444] pci 0000:ff:02.0: completing resume
[18446744061.888446] pci 0000:ff:00.1: completing resume
[18446744061.888448] pci 0000:ff:00.0: completing resume
[18446744061.888450] platform dock.2: completing resume
[18446744061.888452] platform dock.1: completing resume
[18446744061.888454] platform dock.0: completing resume
[18446744061.888555] PM: Finishing wakeup.
[18446744061.888557] Restarting tasks ...=20
[18446744061.906583] PM: Removing info for No Bus:pan0
[18446744061.919401] done.
[18446744061.919406] video LNXVIDEO:00: Restoring backlight state
[18446744062.542216] usb 1-1.4: new full speed USB device using ehci_hcd an=
d address 16
[18446744062.632381] PM: Adding info for usb:1-1.4
[18446744062.632646] PM: Adding info for usb:1-1.4:1.0
[18446744062.632988] PM: Adding info for No Bus:hci0
[18446744062.633040] PM: Adding info for No Bus:rfkill7
[18446744062.633096] PM: Adding info for No Bus:ep_81
[18446744062.633114] PM: Adding info for No Bus:ep_82
[18446744062.633128] PM: Adding info for No Bus:ep_02
[18446744062.633147] PM: Adding info for usb:1-1.4:1.1
[18446744062.633190] PM: Adding info for No Bus:ep_83
[18446744062.633213] PM: Adding info for No Bus:ep_03
[18446744062.633233] PM: Adding info for usb:1-1.4:1.2
[18446744062.633300] PM: Adding info for No Bus:ep_84
[18446744062.633316] PM: Adding info for No Bus:ep_04
[18446744062.633334] PM: Adding info for usb:1-1.4:1.3
[18446744062.633401] PM: Adding info for No Bus:ep_00
[18446744062.643167] PM: Adding info for No Bus:pan0
[ 1298.940728] thinkpad_acpi: EC reports that Thermal Table has changed
[ 1299.028281] ACPI: \_SB_.GDCK - docking
[ 1299.032582] ata2: exception Emask 0x10 SAct 0x0 SErr 0x0 action 0xe froz=
en
[ 1299.032589] ata2: ACPI event
[ 1299.032604] ata2: hard resetting link
[ 1299.032865] PM: Adding info for acpi:device:35
[ 1299.034568] PM: Adding info for acpi:IBM0079:03
[ 1300.087934] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[ 1300.093031] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[ 1300.093875] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[ 1300.097541] ata2.00: ATAPI: HL-DT-ST DVDRAM GSA-U20N, HX12, max UDMA/133
[ 1300.099216] ACPI: \_SB_.PCI0.SAT1.PRT1 - docking
[ 1300.099710] PM: Adding info for acpi:LNXIOBAY:03
[ 1300.099769] ata2.00: failed to IDENTIFY (I/O error, err_mask=3D0x100)
[ 1300.099772] ata2.00: revalidation failed (errno=3D-5)
[ 1300.106200] usb 1-1.5: new high speed USB device using ehci_hcd and addr=
ess 17
[ 1300.181122] PM: Adding info for usb:1-1.5
[ 1300.181545] PM: Adding info for usb:1-1.5:1.0
[ 1300.181575] hub 1-1.5:1.0: USB hub found
[ 1300.181754] hub 1-1.5:1.0: 4 ports detected
[ 1300.181886] PM: Adding info for No Bus:ep_81
[ 1300.182642] PM: Adding info for No Bus:ep_00
[ 1300.455341] usb 1-1.5.3: new full speed USB device using ehci_hcd and ad=
dress 18
[ 1300.543526] PM: Adding info for usb:1-1.5.3
[ 1300.543793] PM: Adding info for usb:1-1.5.3:1.0
[ 1300.544333] PM: Adding info for No Bus:ep_83
[ 1300.544364] PM: Adding info for usb:1-1.5.3:1.1
[ 1300.544432] PM: Adding info for No Bus:ep_00
[ 1300.915639] PM: Adding info for No Bus:ep_81
[ 1300.915655] PM: Adding info for No Bus:ep_02
[ 1300.916057] PM: Adding info for No Bus:usb0
[ 1300.916534] cdc_ether 1-1.5.3:1.0: usb0: register 'cdc_ether' at usb-000=
0:00:1a.0-1.5.3, CDC Ethernet Device, ca:ef:60:b9:fc:a3
[ 1300.916552] usbcore: registered new interface driver cdc_ether
[ 1305.078353] ata2: hard resetting link
[ 1305.535461] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[ 1305.541104] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[ 1305.542062] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[ 1305.552690] ata2.00: ACPI cmd e3/00:1f:00:00:00:a0 (IDLE) succeeded
[ 1305.553588] ata2.00: ACPI cmd e3/00:02:00:00:00:a0 (IDLE) succeeded
[ 1305.557517] ata2.00: configured for UDMA/133
[ 1305.668907] ata2: EH complete
[ 1305.672002] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVDRAM GSA-U20N  HX=
12 PQ: 0 ANSI: 5
[ 1305.672028] PM: Adding info for scsi:target1:0:0
[ 1305.672076] PM: Adding info for scsi:1:0:0:0
[ 1305.994836] usb 1-1.5.2: new high speed USB device using ehci_hcd and ad=
dress 19
[ 1306.001539] sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 =
cdda tray
[ 1306.001586] PM: Adding info for No Bus:sr0
[ 1306.001674] PM: Adding info for No Bus:11:0
[ 1306.001700] sr 1:0:0:0: Attached scsi CD-ROM sr0
[ 1306.001721] PM: Adding info for No Bus:1:0:0:0
[ 1306.001847] PM: Adding info for No Bus:sg1
[ 1306.001866] sr 1:0:0:0: Attached scsi generic sg1 type 5
[ 1306.001917] PM: Adding info for No Bus:1:0:0:0
[ 1306.081682] PM: Adding info for usb:1-1.5.2
[ 1306.082132] PM: Adding info for usb:1-1.5.2:1.0
[ 1306.083084] usb-storage 1-1.5.2:1.0: Quirks match for vid 1058 pid 0704:=
 8000
[ 1306.083112] scsi9 : usb-storage 1-1.5.2:1.0
[ 1306.083128] PM: Adding info for scsi:host9
[ 1306.083173] PM: Adding info for No Bus:host9
[ 1306.083243] PM: Adding info for No Bus:ep_81
[ 1306.083257] PM: Adding info for No Bus:ep_02
[ 1306.083277] PM: Adding info for No Bus:ep_00
[ 1307.081918] scsi 9:0:0:0: Direct-Access     WD       5000BMV External 1.=
75 PQ: 0 ANSI: 4
[ 1307.081948] PM: Adding info for scsi:target9:0:0
[ 1307.082001] PM: Adding info for scsi:9:0:0:0
[ 1307.082055] PM: Adding info for No Bus:9:0:0:0
[ 1307.082104] PM: Adding info for No Bus:9:0:0:0
[ 1307.082245] PM: Adding info for No Bus:sg2
[ 1307.082272] sd 9:0:0:0: Attached scsi generic sg2 type 0
[ 1307.082332] PM: Adding info for No Bus:9:0:0:0
[ 1307.091103] sd 9:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB=
/465 GiB)
[ 1307.091611] sd 9:0:0:0: [sdb] Write Protect is off
[ 1307.091613] sd 9:0:0:0: [sdb] Mode Sense: 23 00 00 00
[ 1307.091615] sd 9:0:0:0: [sdb] Assuming drive cache: write through
[ 1307.091648] PM: Adding info for No Bus:sdb
[ 1307.092864] sd 9:0:0:0: [sdb] Assuming drive cache: write through
[ 1307.092871]  sdb: unknown partition table
[ 1307.119886] PM: Adding info for No Bus:8:16
[ 1307.121423] sd 9:0:0:0: [sdb] Assuming drive cache: write through
[ 1307.121426] sd 9:0:0:0: [sdb] Attached SCSI disk
[ 1394.731227] usb0: no IPv6 routers present
[ 1523.903817] device usb0 entered promiscuous mode
[ 1722.123466] usb 1-1.5.3: USB disconnect, address 18
[ 1722.123596] PM: Removing info for No Bus:ep_83
[ 1722.123638] PM: Removing info for usb:1-1.5.3:1.0
[ 1722.123667] cdc_ether 1-1.5.3:1.0: usb0: unregister 'cdc_ether' usb-0000=
:00:1a.0-1.5.3, CDC Ethernet Device
[ 1722.143548] PM: Removing info for No Bus:usb0
[ 1722.148971] PM: Removing info for No Bus:ep_81
[ 1722.148988] PM: Removing info for No Bus:ep_02
[ 1722.149000] PM: Removing info for usb:1-1.5.3:1.1
[ 1722.149036] PM: Removing info for No Bus:ep_00
[ 1722.149053] PM: Removing info for usb:1-1.5.3
[ 1727.156200] usb 1-1.5.3: new full speed USB device using ehci_hcd and ad=
dress 20
[ 1727.244520] PM: Adding info for usb:1-1.5.3
[ 1727.245290] PM: Adding info for usb:1-1.5.3:1.0
[ 1727.245714] PM: Adding info for No Bus:ep_81
[ 1727.245742] PM: Adding info for usb:1-1.5.3:1.1
[ 1727.246087] PM: Adding info for No Bus:ep_02
[ 1727.246111] PM: Adding info for No Bus:ep_83
[ 1727.246142] PM: Adding info for usb:1-1.5.3:1.2
[ 1727.246465] PM: Adding info for No Bus:ep_00
[ 1727.319440] cdc_acm 1-1.5.3:1.0: This device cannot do calls on its own.=
 It is not a modem.
[ 1727.319462] cdc_acm 1-1.5.3:1.0: ttyACM0: USB ACM device
[ 1727.319991] PM: Adding info for No Bus:ttyACM0
[ 1727.320022] usbcore: registered new interface driver cdc_acm
[ 1727.320024] cdc_acm: v0.26:USB Abstract Control Model driver for USB mod=
ems and ISDN adapters
[ 1733.368959] usb 1-1.5.3: USB disconnect, address 20
[ 1733.368971] PM: Removing info for No Bus:ep_81
[ 1733.368996] PM: Removing info for usb:1-1.5.3:1.0
[ 1733.369101] PM: Removing info for No Bus:ttyACM0
[ 1733.369319] PM: Removing info for No Bus:ep_02
[ 1733.369339] PM: Removing info for No Bus:ep_83
[ 1733.369356] PM: Removing info for usb:1-1.5.3:1.1
[ 1733.369393] PM: Removing info for usb:1-1.5.3:1.2
[ 1733.369432] PM: Removing info for No Bus:ep_00
[ 1733.369453] PM: Removing info for usb:1-1.5.3
[ 1782.867925] usb 1-1.5.3: new full speed USB device using ehci_hcd and ad=
dress 21
[ 1782.957117] PM: Adding info for usb:1-1.5.3
[ 1782.957396] PM: Adding info for usb:1-1.5.3:1.0
[ 1782.958332] PM: Adding info for No Bus:usb0
[ 1782.959464] cdc_ether 1-1.5.3:1.0: usb0: register 'cdc_ether' at usb-000=
0:00:1a.0-1.5.3, CDC Ethernet Device, 5a:78:4d:f7:51:fa
[ 1782.959497] PM: Adding info for No Bus:ep_83
[ 1782.959519] PM: Adding info for usb:1-1.5.3:1.1
[ 1782.959899] PM: Adding info for No Bus:ep_81
[ 1782.959924] PM: Adding info for No Bus:ep_02
[ 1782.959951] PM: Adding info for No Bus:ep_00
[ 1798.984057] usb0: no IPv6 routers present
[ 1823.721466] ip_tables: (C) 2000-2006 Netfilter Core Team
[ 1823.747977] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[ 1823.748287] CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Pl=
ease use
[ 1823.748290] nf_conntrack.acct=3D1 kernel parameter, acct=3D1 nf_conntrac=
k module option or
[ 1823.748292] sysctl net.netfilter.nf_conntrack_acct=3D1 to enable it.
[ 1972.790492] device usb0 entered promiscuous mode
[ 1975.441710] device usb0 left promiscuous mode
[ 1977.982659] device usb0 entered promiscuous mode
[ 1980.437365] device usb0 left promiscuous mode
[ 1996.318574] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ 1997.416253] wlan0: deauthenticating from 00:05:4e:4d:82:6d by local choi=
ce (reason=3D3)
[ 1997.429500] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[ 1997.514819] wlan0: authenticated
[ 1997.525562] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[ 1997.724838] wlan0: associate with 00:05:4e:4d:82:6d (try 2)
[ 1997.728137] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[ 1997.728143] wlan0: associated
[ 1997.734064] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[ 2008.735883] wlan0: no IPv6 routers present
[ 2527.863872] PM: Adding info for No Bus:tun0
[ 2527.864180] tun0: Disabled Privacy Extensions
[ 2529.452508] PM: Removing info for No Bus:tun0
[ 2532.586620] device usb0 entered promiscuous mode
[ 2534.291632] device usb0 left promiscuous mode
[ 2545.224349] device wlan0 entered promiscuous mode
[ 2547.193165] device wlan0 left promiscuous mode
[ 2550.537387] device wlan0 entered promiscuous mode
[ 2552.184524] device wlan0 left promiscuous mode
[23237.564953] PM: Adding info for No Bus:dm-2
[23237.565020] PM: Adding info for No Bus:254:2
[23237.594540] PM: Removing info for No Bus:254:2
[23237.594593] PM: Removing info for No Bus:dm-2
[23237.605680] PM: Adding info for No Bus:dm-2
[23237.605743] PM: Adding info for No Bus:254:2
[25506.068320] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25506.081118] cfg80211: Calling CRDA to update world regulatory domain
[25509.600812] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25509.637329] wlan0: authenticated
[25509.641287] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25509.840122] wlan0: associate with 00:05:4e:4d:82:6d (try 2)
[25509.847855] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25509.847859] wlan0: associated
[25538.006386] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25538.022841] cfg80211: Calling CRDA to update world regulatory domain
[25541.402684] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25541.602533] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25541.629322] wlan0: authenticated
[25541.632848] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25541.644457] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25541.644461] wlan0: associated
[25559.964492] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25559.981004] cfg80211: Calling CRDA to update world regulatory domain
[25563.291903] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25563.295176] wlan0: authenticated
[25563.296867] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25563.496751] wlan0: associate with 00:05:4e:4d:82:6d (try 2)
[25563.499083] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25563.499087] wlan0: associated
[25605.877896] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25605.891966] cfg80211: Calling CRDA to update world regulatory domain
[25609.205316] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25609.405168] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25609.406926] wlan0: authenticated
[25609.408993] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25609.430817] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25609.430821] wlan0: associated
[25635.819773] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25635.833582] cfg80211: Calling CRDA to update world regulatory domain
[25639.150899] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25639.351036] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25639.352901] wlan0: authenticated
[25639.356350] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25639.365733] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25639.365737] wlan0: associated
[25649.809085] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25649.822830] cfg80211: Calling CRDA to update world regulatory domain
[25661.418918] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25661.618555] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25661.620368] wlan0: authenticated
[25661.623787] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25661.629942] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25661.629946] wlan0: associated
[25725.648398] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25725.666166] cfg80211: Calling CRDA to update world regulatory domain
[25728.999742] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25729.003491] wlan0: authenticated
[25729.006977] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25729.013579] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25729.013583] wlan0: associated
[25765.573229] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25765.589099] cfg80211: Calling CRDA to update world regulatory domain
[25777.111681] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25777.311343] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25777.315654] wlan0: authenticated
[25777.319200] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25777.330780] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25777.330784] wlan0: associated
[25797.510964] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25797.527051] cfg80211: Calling CRDA to update world regulatory domain
[25801.027043] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25801.227208] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25801.229015] wlan0: authenticated
[25801.233474] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25801.237689] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25801.237693] wlan0: associated
[25852.406567] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25852.420357] cfg80211: Calling CRDA to update world regulatory domain
[25864.020786] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25864.221027] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25864.222774] wlan0: authenticated
[25864.226233] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25864.232738] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25864.232742] wlan0: associated
[25982.159023] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[25982.173918] cfg80211: Calling CRDA to update world regulatory domain
[25985.557397] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[25985.757160] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[25985.760176] wlan0: authenticated
[25985.766261] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[25985.776730] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[25985.776734] wlan0: associated
[26026.074282] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[26026.083515] cfg80211: Calling CRDA to update world regulatory domain
[26037.588253] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[26037.787906] wlan0: authenticate with 00:05:4e:4d:82:6d (try 2)
[26037.791250] wlan0: authenticated
[26037.794831] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[26037.801060] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[26037.801064] wlan0: associated
[26338.480229] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[26338.494903] cfg80211: Calling CRDA to update world regulatory domain
[26341.801566] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[26341.804082] wlan0: authenticated
[26341.808385] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[26342.008495] wlan0: associate with 00:05:4e:4d:82:6d (try 2)
[26342.010831] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[26342.010835] wlan0: associated
[26826.548091] No probe response from AP 00:05:4e:4d:82:6d after 500ms, dis=
connecting.
[26826.561736] cfg80211: Calling CRDA to update world regulatory domain
[26829.846634] wlan0: authenticate with 00:05:4e:4d:82:6d (try 1)
[26829.850684] wlan0: authenticated
[26829.854098] wlan0: associate with 00:05:4e:4d:82:6d (try 1)
[26830.054395] wlan0: associate with 00:05:4e:4d:82:6d (try 2)
[26830.056804] wlan0: RX AssocResp from 00:05:4e:4d:82:6d (capab=3D0x401 st=
atus=3D0 aid=3D1)
[26830.056808] wlan0: associated
[27993.303399] PM: Removing info for No Bus:254:2
[27993.303437] PM: Removing info for No Bus:dm-2

--=20
New PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
Please resign, if you signed 9885188C or 8D0E27A4.

Currently moving *.schottelius.org to http://www.nico.schottelius.org/ ...

--JP+T4n/bALQSJXh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=ethtool-eth0

driver: e1000e
version: 1.0.2-k4
firmware-version: 0.12-1
bus-info: 0000:00:19.0

--JP+T4n/bALQSJXh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=lspci-vv

00:00.0 Host bridge: Intel Corporation Core Processor DRAM Controller (rev 02)
	Subsystem: Lenovo Device 2193
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
	Kernel driver in use: agpgart-intel
	Kernel modules: intel-agp

00:02.0 VGA compatible controller: Intel Corporation Core Processor Integrated Graphics Controller (rev 02) (prog-if 00 [VGA controller])
	Subsystem: Lenovo Device 215a
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 47
	Region 0: Memory at f2000000 (64-bit, non-prefetchable) [size=4M]
	Region 2: Memory at d0000000 (64-bit, prefetchable) [size=256M]
	Region 4: I/O ports at 1800 [size=8]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4199
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a4] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: i915

00:16.0 Communication controller: Intel Corporation 5 Series/3400 Series Chipset HECI Controller (rev 06)
	Subsystem: Lenovo Device 215f
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f2727800 (64-bit, non-prefetchable) [size=16]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [8c] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000

00:16.3 Serial controller: Intel Corporation 5 Series/3400 Series Chipset KT Controller (rev 06) (prog-if 02 [16550])
	Subsystem: Lenovo Device 2162
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 17
	Region 0: I/O ports at 1808 [size=8]
	Region 1: Memory at f2524000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [c8] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: serial
	Kernel modules: 8250_pci

00:19.0 Ethernet controller: Intel Corporation 82577LM Gigabit Network Connection (rev 06)
	Subsystem: Lenovo Device 2153
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 45
	Region 0: Memory at f2500000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f2525000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at 1820 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 4162
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: e1000e
	Kernel modules: e1000e

00:1a.0 USB Controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 06) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 2163
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 23
	Region 0: Memory at f2728000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd
	Kernel modules: ehci-hcd

00:1b.0 Audio device: Intel Corporation 5 Series/3400 Series Chipset High Definition Audio (rev 06)
	Subsystem: Lenovo Device 215e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 44
	Region 0: Memory at f2520000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 415a
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Kernel driver in use: HDA Intel
	Kernel modules: snd-hda-intel

00:1c.0 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 1 (rev 06) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=0d, subordinate=0d, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #0, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4149
	Capabilities: [90] Subsystem: Lenovo Device 2164
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport

00:1c.3 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 4 (rev 06) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=05, subordinate=0c, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f0000000-f1ffffff
	Prefetchable memory behind bridge: 00000000f2800000-00000000f28fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #3, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4151
	Capabilities: [90] Subsystem: Lenovo Device 2164
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport

00:1c.4 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI Express Root Port 5 (rev 06) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	Memory behind bridge: f2400000-f24fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #4, PowerLimit 10.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range BC, TimeoutDis+ ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0f00c  Data: 4159
	Capabilities: [90] Subsystem: Lenovo Device 2164
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport

00:1d.0 USB Controller: Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller (rev 06) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 2163
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 19
	Region 0: Memory at f2728400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd
	Kernel modules: ehci-hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev a6) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Lenovo Device 2165

00:1f.0 ISA bridge: Intel Corporation Mobile 5 Series Chipset LPC Interface Controller (rev 06)
	Subsystem: Lenovo Device 2166
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=10 <?>

00:1f.2 SATA controller: Intel Corporation 5 Series/3400 Series Chipset 6 port SATA AHCI Controller (rev 06) (prog-if 01 [AHCI 1.0])
	Subsystem: Lenovo Device 2168
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 43
	Region 0: I/O ports at 1860 [size=8]
	Region 1: I/O ports at 1814 [size=4]
	Region 2: I/O ports at 1818 [size=8]
	Region 3: I/O ports at 1810 [size=4]
	Region 4: I/O ports at 1840 [size=32]
	Region 5: Memory at f2727000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0100c  Data: 4169
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
	Capabilities: [b0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation 5 Series/3400 Series Chipset SMBus Controller (rev 06)
	Subsystem: Lenovo Device 2167
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at f2728800 (64-bit, non-prefetchable) [size=256]
	Region 4: I/O ports at 1880 [size=32]
	Kernel driver in use: i801_smbus
	Kernel modules: i2c-i801

00:1f.6 Signal processing controller: Intel Corporation 5 Series/3400 Series Chipset Thermal Subsystem (rev 06)
	Subsystem: Lenovo Device 2190
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin D routed to IRQ 11
	Region 0: Memory at f2526000 (64-bit, non-prefetchable) [size=4K]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000

02:00.0 Network controller: Intel Corporation WiFi Link 6000 Series (rev 35)
	Subsystem: Intel Corporation WiFi Link 6000 Series 3x3 6000AGN
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 46
	Region 0: Memory at f2400000 (64-bit, non-prefetchable) [size=8K]
	Capabilities: [c8] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0100c  Data: 4191
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <32us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Kernel driver in use: iwlagn
	Kernel modules: iwlagn

ff:00.0 Host bridge: Intel Corporation Core Processor QuickPath Architecture Generic Non-core Registers (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:00.1 Host bridge: Intel Corporation Core Processor QuickPath Architecture System Address Decoder (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.0 Host bridge: Intel Corporation Core Processor QPI Link 0 (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.1 Host bridge: Intel Corporation Core Processor QPI Physical 0 (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.2 Host bridge: Intel Corporation Core Processor Reserved (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

ff:02.3 Host bridge: Intel Corporation Core Processor Reserved (rev 02)
	Subsystem: Lenovo Device 2196
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0


--JP+T4n/bALQSJXh8
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="config.gz"
Content-Transfer-Encoding: base64

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
s0wdd1miHiMnZd10Zov/B76xf3/YsgEA

--JP+T4n/bALQSJXh8--

--Bu8it7iiRSEf40bY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwu8hwACgkQ19zI5DGHffDBvACeNhTOjKu460kyTeJRSnIic8ys
gFMAnjDWTXr0I5NlCFKyppj0yPMypMJT
=BSdJ
-----END PGP SIGNATURE-----

--Bu8it7iiRSEf40bY--
