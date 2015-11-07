From: Sverd Johnsen <sverd.johnsen@googlemail.com>
Subject: 4.3.0 r8169: "rtl_counters_cond == 1 (loop: 1000, delay: 10)." log spam
Date: Sat, 7 Nov 2015 05:07:36 +0100
Message-ID: <CAGmahrQeczagrfAc-cbGnDrDW4c3DNwAZCn=ZYkRo=q9wnge5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36250 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbKGEHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 23:07:37 -0500
Received: by oiww189 with SMTP id w189so52485430oiw.3
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 20:07:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

related:

https://bugzilla.kernel.org/show_bug.cgi?id=107421
https://bugzilla.kernel.org/show_bug.cgi?id=104351

4.3.0 smp x86_64

[    4.384336] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    4.384747] r8169 0000:0e:00.0 eth0: RTL8101e at
0xffffc90000060000, 00:1b:38:b5:9f:d6, XID 94200000 IRQ 29
[   13.288711] r8169 0000:0e:00.0 enp14s0: renamed from eth0
[   13.317747] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   28.238567] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   28.904171] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   28.923315] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   29.029901] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   30.562934] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   30.740113] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   31.232822] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   32.519930] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   32.536962] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.311612] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.328095] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.474262] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.493735] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.657576] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.674116] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.851311] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.867912] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.004213] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.025282] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.086090] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.102623] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.148333] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.165005] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.210847] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.227479] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.274966] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.291638] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.342473] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.358967] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.404815] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.421305] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.466806] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.483506] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.531613] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.548165] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.596182] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.613536] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.675545] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.699661] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.746621] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.763151] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.808652] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.825145] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.871819] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.888318] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.933838] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.950440] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.536276] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.552772] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.708147] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.724832] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.889057] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.905662] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.950317] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.967924] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   36.096605] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   36.113932] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   36.131298] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   36.148587] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   46.511024] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   48.304603] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   61.528387] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   76.545869] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   91.563233] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  106.580576] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  119.670595] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  121.597940] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  136.615290] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  151.632648] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  166.649970] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  181.667356] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  196.684759] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  211.702155] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  226.719488] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  241.736897] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  256.754369] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  271.771826] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  271.789052] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  286.806618] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  301.824017] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  316.841431] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  331.858860] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  346.876312] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  361.893768] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  376.911245] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  391.928647] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  406.946073] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  421.963516] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  436.980970] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  451.998417] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  467.015869] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  482.033358] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  497.050848] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  512.068346] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[  512.085675] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).



0e:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 01)
        Subsystem: Toshiba America Info Systems RTL8101E/RTL8102E PCI
Express Fast Ethernet controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 29
        Region 0: I/O ports at a000 [size=256]
        Region 2: Memory at f8100000 (64-bit, non-prefetchable) [size=4K]
        [virtual] Expansion ROM at f8120000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D3 NoSoftRst- PME-Enable+ DSel=0 DScale=0 PME-
        Capabilities: [48] Vital Product Data
                Unknown small resource type 05, will not decode more.
        Capabilities: [50] MSI: Enable+ Count=1/2 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [60] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
<128ns, L1 unlimited
                        ExtTag+ AttnBtn+ AttnInd+ PwrInd+ RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s,
Exit Latency L0s unlimited, L1 unlimited
                        ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [84] Vendor Specific Information: Len=4c <?>
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [12c v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed- WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
        Capabilities: [148 v1] Device Serial Number 02-00-00-00-10-ec-81-36
        Capabilities: [154 v1] Power Budgeting <?>
        Kernel driver in use: r8169
