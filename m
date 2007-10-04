From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [BUGZILLA] network device bugs
Date: Thu, 4 Oct 2007 09:45:05 -0700
Message-ID: <20071004094505.10f2003b@freepuppy.rosehill>
References: <20071004094426.5321af0e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42836 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759384AbXJDQsT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 12:48:19 -0400
Received: from freepuppy.rosehill (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l94GmEgI001563
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 09:48:18 -0700
In-Reply-To: <20071004094426.5321af0e@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

94 bugs found.

ID  	 Assignee  	 Status  	 Resolution  	 Version  	 Summary
2283 	c-d.hailfinger.kernel.2004@... 	ASSI 		2.6.3 	(net forcedeth) NET=
DEV WATCHDOG: eth1: transmit timed out...
2776 	grundler@parisc-linux.org 	ASSI 		2.6.5 	(net dmfe) Davicom 9102A=
=46 only works in 10 Mbps
3048 	jgarzik@pobox.com 	NEW 		>=3D2.6.6 	(IRDA) smsc-ircc2: can't get =
sir_base of 0x2f8
3050 	jgarzik@pobox.com 	NEW 		2.6.7 	(net b44) Link is down! problem
3156 	grundler@parisc-linux.org 	NEW 		2.6.7 stock kernel 	(net de2104x=
) Kernel panic with de2104x tulip driver on boot
3299 	jgarzik@pobox.com 	NEW 		2.6.8-1 	(net tlan) receives interrupt f=
or uncompleted RX frame du...
3526 	jgarzik@pobox.com 	NEW 		2.6.8.1 	(net 8139too) CardBus NIC locks=
 up system with PIO
3575 	jgarzik@pobox.com 	NEW 		2.6.8.1 	(IRDA) PNP Support in nsc-ircc
3661 	jgarzik@pobox.com 	NEW 		2.6.8.1 / 2.6.9 	(net 8139too) gives str=
ange errors, drops and overruns in...
3765 	jgarzik@pobox.com 	NEW 		2.6.9 (also 2.6... 	Network link down, w=
hen writting to sata disk AND network...
3777 	jgarzik@pobox.com 	NEW 		2.6.10-rc2 	(net tun) driver fails to op=
en when built in, must be mod...
3801 	jgarzik@pobox.com 	NEW 		2.6.9 	(net 8139too) does not set PME-En=
able upon setting WOL
3938 	jgarzik@pobox.com 	NEW 		2.6.9 	(net tun) device driver doesn't f=
ill in interface name on...
4143 	jgarzik@pobox.com 	NEW 		2.6.10 	(net via-rhine) my eth card (via=
-rhine HP xe4100 laptop) ...
4420 	grundler@parisc-linux.org 	NEW 		2.6.11.6 	(net tulip) Problem wi=
th 6 bit addressing in tulip_read_e...
4434 	grundler@parisc-linux.org 	NEW 		2.6.11 	(net Tulip) NIC card cau=
ses hard lock up of PC
4451 	jgarzik@pobox.com 	NEW 		2.6.9 	(net via-rhine) VIA Rhine II: med=
ia detection fails on re...
4566 	jgarzik@pobox.com 	NEW 		2.6.11 	(net B44) Randomly driver starts=
 sending garbage and stop...
4701 	grundler@parisc-linux.org 	ASSI 		2.6.11.11, also... 	(net tulip)=
 No driver works with Asant=EF=BF=BDFAST 10/100 PWA ...
4755 	jgarzik@pobox.com 	NEW 		2.6.11.11 	At system startup b44 doesn't=
 report correct mii status
4803 	jgarzik@pobox.com 	NEW 		2.6.12 	3c59x: regression in time to est=
ablish connection
4844 	jgarzik@pobox.com 	NEW 		2.6.12.1 	HERMES driver should be more s=
pecific about IPW support
4849 	jgarzik@pobox.com 	NEW 		2.6.12.1 - 2.6.... 	WAKE ON LAN not work=
ing.
4883 	jgarzik@pobox.com 	NEW 		2.6.12.2 	tg3 driver doesn't send ARP re=
ply on 8021q 802.1q dot1q V...
5033 	jgarzik@pobox.com 	NEW 		2.6.12 (and pre... 	NIC responds only ev=
ery N seconds
5149 	auke-jan.h.kok@intel.com 	ASSI 		2.6.13 	Wake-on-lan broken using=
 Intel e100 driver
5519 	jgarzik@pobox.com 	NEW 		2.6.14 	Bonding Driver Marks itself as n=
ot VLAN Capable
5569 	jgarzik@pobox.com 	NEW 		2.6.14 	xirc2ps_cs based pcmcia card sto=
pped working in 2.6.14
5624 	jgarzik@pobox.com 	NEW 		2.6.15-rc1 	Lockup in B44 driver on 'mii=
-tool ethX' when 'ifconfig et...
5827 	jgarzik@pobox.com 	NEW 		2.6.15 	pppd with MPPE fails
5839 	grundler@parisc-linux.org 	ASSI 		2.6.15 	uli526x partially recog=
nizing interface
5870 	romieu@fr.zoreil.com 	ASSI 		2.6.15 	SiS 190 doesn't download fil=
es
5979 	jgarzik@pobox.com 	NEW 		2.6.15.1 	Davicom DM9102 Network Card cu=
ts out every 60 secs
6108 	romieu@fr.zoreil.com 	ASSI 		2.6.15.3 	Failure of r8169 ethernet =
i/f after resume from S3 sleep
6149 	jgarzik@pobox.com 	NEW 		2.6.15.5 	Fiber Optic interface don't wo=
rks on 3c905B-FX
6366 	jgarzik@pobox.com 	NEW 		2.6.16.1 + susp... 	Oversized Ethernet f=
rame spanned multiple buffers
6444 	jgarzik@pobox.com 	NEW 		2.6.16.7 	transmit timed out on 3c59x
6610 	jgarzik@pobox.com 	NEW 		2.6.16 	dummy interface broadcast destin=
ation hardware address is...
6690 	jgarzik@pobox.com 	NEW 		2.6.16.16 	forcedeth 0.57 problems at gi=
gabit speeds
6807 	romieu@fr.zoreil.com 	ASSI 		2.6.16.17 	r8169: freeze at higher s=
peeds
6929 	auke-jan.h.kok@intel.com 	ASSI 		2.6.17.1 	T60 and e1000 long pin=
g
6986 	auke-jan.h.kok@intel.com 	ASSI 		2.6.15 	e1000 doesn't update tra=
fic counters frequently enough
7071 	jgarzik@pobox.com 	NEW 		2.6.17.11 #2 SM... 	Can't bring Sun Quad=
 GigaSwift Ethernet interfaces up (Ca...
7085 	romieu@fr.zoreil.com 	ASSI 		2.6.17.11 	System freezes when load =
the module sis190
7133 	jgarzik@pobox.com 	NEW 		2.6.17 	ibmtr_cs seams working as fine w=
ith 64bit kernel than wit...
7226 	jgarzik@pobox.com 	NEW 		2.4.33 / 2.6.18 	Problem in forcing RTL8=
139 into 100Mbps full-duplex mode
7440 	jgarzik@pobox.com 	NEW 		2.6.18.1 	3c59x suddenly receives no mor=
e packets
7443 	jgarzik@pobox.com 	NEW 		2.6.18.1 	8139too and transmit timeouts =
with edge triggered PCI irq
7487 	jgarzik@pobox.com 	NEW 		2.6.19-rc5/2.6.... 	Sundance driver fail=
s to recognize carrier status
7588 	jgarzik@pobox.com 	NEW 		2.6.19 	Race: Lock is not acquired befor=
e calling read_zsreg in z...
7617 	shemminger@osdl.org 	REOP 		2.6.19-rc6-mm2 	sky2 driver crashes
7633 	jgarzik@pobox.com 	NEW 		2.6.20.1 	Race: Caller of function alb_s=
wap_mac_addr() must hold bo...
7659 	jgarzik@pobox.com 	NEW 		2.6.19 	Race: a lock must be held before=
 entering update_stats
7660 	jgarzik@pobox.com 	NEW 		2.6.19 	Race: lock must be held before e=
ntering function z8530_re...
7696 	jgarzik@pobox.com 	NEW 		2.6.20_rc1 	b44 driver doesn't work unde=
r heavy load
7821 	romieu@fr.zoreil.com 	ASSI 		2.6.20-rc5 	sundance driver not acti=
vating D-Link DFE-580TX adapter
7853 	jgarzik@pobox.com 	NEW 		2.6.16.37 	Get "mppe_decompress: osize t=
oo small" while forwarding f...
7856 	jgarzik@pobox.com 	NEW 		2.6.19.2 	b44 WOL problem (bcm4401)
7924 	romieu@fr.zoreil.com 	ASSI 		2.6.19.2 	same issue as closed bug 7=
555 with r8169 and slow transfer
8007 	jgarzik@pobox.com 	NEW 		2.6.20 	3c905 Tornado dosen't work (eepr=
om mac address is invalid)
8009 	jgarzik@pobox.com 	NEW 		linux-2.6.18 	PPPoE+mppe Server fail wit=
h Win Client
8043 	jesse.brandeburg@intel.com 	NEW 		2.6.18.7 	curious communication=
 breakage with e1000 and NBT
8061 	romieu@fr.zoreil.com 	ASSI 		2.6.20 	is VIA Network device statis=
tics calculation wrong? missi...
8084 	jgarzik@pobox.com 	NEW 		Linux-2.6.20 	phy_mii_ioctl(...) forgets=
 to return phy_device's speed s...
8106 	broonie@sirena.org.uk 	ASSI 		2.6.20 	tx_errors and tx_fifo_error=
s not updated consistantly
8107 	jgarzik@pobox.com 	NEW 		2.6.20 	dev->header_cache_update has a r=
andom value
8132 	jgarzik@pobox.com 	NEW 		2.6.20 	pptp server lockup in ppp_asynct=
ty_receive()
8143 	romieu@fr.zoreil.com 	ASSI 		2.6.20.1 	System freeze when two app=
lications access a NAS while it...
8146 	jgarzik@pobox.com 	NEW 		2.6.20.1 	A bug or a bad comment? scc_ne=
t_rx is not called from sc...
8252 	romieu@fr.zoreil.com 	ASSI 		2.6.20.3 	Via Velocity "eth0: excess=
ive work at interrupt."
8329 	Eric.Moore@lsil.com 	NEW 		2.6.20 	mtplan.c: kmalloc while spinlo=
ck is held
8330 	jgarzik@pobox.com 	NEW 		2.6.20 	lmc: copy_to/from_user cals whil=
e spinlock is held
8381 	jgarzik@pobox.com 	NEW 		2.6.21-rc5 	forcedeth doesn't wol on sus=
pend
8430 	auke-jan.h.kok@intel.com 	ASSI 		2.6.20.11 	BUG: e1000: schedulin=
g while atomic: mii-tool
8443 	jgarzik@pobox.com 	NEW 		2.6.18-4 	Forcedeth v0.56 delivers MAC-A=
ddress backwards
8568 	aabdulla@nvidia.com 	NEW 		2.6.21.3 	forcedeth: autonegotiation w=
eirdness with dual port nforc...
8604 	aabdulla@nvidia.com 	NEW 		2.6.17-14mdv 	Forcedeth IRQ / soft loc=
kup
8612 	jgarzik@pobox.com 	NEW 		2.6.21.4 	Ethernet spin down (mcp51)
8637 	shemminger@osdl.org 	ASSI 		2.6.22-rc4 	skge doesn't wakeonlan (w=
ol) whilst hibernated
8642 	aabdulla@nvidia.com 	NEW 		2.6.21 	forcedeth doesn't work on MCP6=
1 chipset mainboard
8688 	romieu@fr.zoreil.com 	ASSI 		2.6.21.5 	r8169: high latency when p=
acket fragmentation occurs (NFS)
8699 	jgarzik@pobox.com 	NEW 		2.6.21.5 	bnx2 driver needs delay for VL=
AN tagging
8700 	jgarzik@pobox.com 	NEW 		2.6.21.4 	(forcedeth.c doesn't work corr=
ectly) Any ethernet going down
8733 	jgarzik@pobox.com 	NEW 		2.6.22 	forcedeth stuck in long loop on =
loading
8776 	mchan@broadcom.com 	NEW 		2.6.22.1 	tg3 I/O lockup after a certai=
n number of packets
8780 	mchan@broadcom.com 	NEW 		2.6.21.5 	tg3 crashing
8808 	jgarzik@pobox.com 	NEW 		2.6.22.1 	Large file transfer causes ker=
nel panic showing b44_poll
8952 	grundler@parisc-linux.org 	ASSI 		2.6.22.5 	tulip driver oops in =
tulip_interrupt when hibernating wit...
8981 	jgarzik@pobox.com 	NEW 		2.6.23-rc5 	got a kernel panic with 2.6.=
23-rc5 - something concerning...
8991 	samuel@sortiz.org 	NEW 		2.6.22.5 	(IrDA) nsc-ircc not working an=
ymore since 2.6.22.5
9015 	aabdulla@nvidia.com 	NEW 		2.6.22.6 	network load can break nforc=
e nic (forcedeth driver)
9047 	jgarzik@pobox.com 	REOP 		2.6.23-rc7-git1 	2.6.23-rc7-git1 forced=
eth w/ MCP55 oops under heavy load
9094 	grundler@parisc-linux.org 	ASSI 		2.6.22 	dmfe driver stopped wor=
king correctly in kernel 2.6.22
9106 	grundler@parisc-linux.org 	ASSI 		2.6.22.9 	Sun Fire v100 dmfe dr=
iver bug


--=20
Stephen Hemminger <shemminger@linux-foundation.org>
