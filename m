From: =?iso-8859-1?B?Q2FybG9zIFBl824gQ29zdGE=?= <carlospeon@hotmail.com>
Subject: RE: bnx2x kerneloops
Date: Wed, 2 Nov 2011 12:59:47 +0100
Message-ID: <SNT113-W38A7D5A673342F70A1F808DBD40@phx.gbl>
References: <SNT113-W64251CF45774789989C835DBD40@phx.gbl>,<1320234845.2688.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snt0-omc3-s32.snt0.hotmail.com ([65.55.90.171]:23835 "EHLO
	snt0-omc3-s32.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752306Ab1KBL7r convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 07:59:47 -0400
In-Reply-To: <1320234845.2688.3.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi, It's a HP BL460c G6.
Regards.

02:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57711=
E 10-Gigabit PCIe=A0 =A0 =A0 =A0 Subsystem: Hewlett-Packard Company NC5=
32i Dual Port 10GbE Multifunction BL-C Adapter=A0 =A0 =A0 =A0 Control: =
I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SE=
RR- FastB2B- DisINTx+=A0 =A0 =A0 =A0 Status: Cap+ 66MHz- UDF- FastB2B- =
ParErr- DEVSEL=3Dfast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-=A0=
 =A0 =A0 =A0 Latency: 0, Cache Line Size: 64 bytes=A0 =A0 =A0 =A0 Inter=
rupt: pin A routed to IRQ 28=A0 =A0 =A0 =A0 Region 0: Memory at fb00000=
0 (64-bit, non-prefetchable) [size=3D8M]=A0 =A0 =A0 =A0 Region 2: Memor=
y at fa800000 (64-bit, non-prefetchable) [size=3D8M]=A0 =A0 =A0 =A0 [vi=
rtual] Expansion ROM at e4000000 [disabled] [size=3D64K]=A0 =A0 =A0 =A0=
 Capabilities: [48] Power Management version 3=A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0+,D1-,D2-,D3hot=
+,D3cold+)=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Status: D0 NoSoftRst+ PME-Ena=
ble- DSel=3D0 DScale=3D1 PME-=A0 =A0 =A0 =A0 Capabilities: [50] Vital P=
roduct Data=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Product Name: HP_NC532i_DP_1=
0GbE_Multifunction_BL-c_Adapter=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Read-onl=
y fields:=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [PN] Part numb=
er: N/A=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [EC] Engineering=
 changes: N/A=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [SN] Seria=
l number: 0123456789=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [MN=
] Manufacture ID: 31 34 65 34=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 [RV] Reserved: checksum good, 39 byte(s) reserved=A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 End=A0 =A0 =A0 =A0 Capabilities: [58] MSI: Enable- Count=3D=
1/8 Maskable- 64bit+=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Address: 0000000000=
000000 =A0Data: 0000=A0 =A0 =A0 =A0 Capabilities: [a0] MSI-X: Enable+ C=
ount=3D17 Masked-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Vector table: BAR=3D0 =
offset=3D00440000=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PBA: BAR=3D0 offset=3D=
00441800=A0 =A0 =A0 =A0 Capabilities: [ac] Express (v2) Endpoint, MSI 0=
0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DevCap: MaxPayload 512 bytes, PhantFun=
c 0, Latency L0s <1us, L1 <2us=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-=A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsu=
pported-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RlxdOrd+ ExtTag=
- PhantFunc- AuxPwr+ NoSnoop+=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 MaxPayload 256 bytes, MaxReadReq 4096 bytes=A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ Trans=
Pend-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 LnkCap: Port #0, Speed 5GT/s, Widt=
h x8, ASPM L0s L1, Latency L0 <4us, L1 <4us=A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 ClockPM- Surprise- LLActRep- BwNot-=A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- =
CommClk-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ExtSynch- Clock=
PM- AutWidDis- BWInt- AutBWInt-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 LnkSta: =
Speed 5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt=
-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DevCap2: Completion Timeout: Range ABC=
D, TimeoutDis+=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DevCtl2: Completion Timeo=
ut: 50us to 50ms, TimeoutDis-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 LnkCtl2: T=
arget Link Speed: 5GT/s, EnterCompliance- SpeedDis-, Selectable De-emph=
asis: -6dB=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Transmit M=
argin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-=A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Compliance De-emphasis:=
 -6dB=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 LnkSta2: Current De-emphasis Level=
: -6dB=A0 =A0 =A0 =A0 Capabilities: [100] Device Serial Number d8-d3-85=
-ff-fe-59-86-48=A0 =A0 =A0 =A0 Capabilities: [110] Advanced Error Repor=
ting=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 UESta: =A0DLP- SDES- TLP- FCP- Cmpl=
tTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-=A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 UEMsk: =A0DLP- SDES- TLP- FCP- CmpltTO- CmpltA=
brt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-=A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 UESvrt: DLP- SDES+ TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-=
 RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 CESta: =A0RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-=A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 CEMsk: =A0RxErr- BadTLP- BadDLLP- Rollover- Ti=
meout- NonFatalErr-=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 AERCap: First Error =
Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-=A0 =A0 =A0 =A0 Capabilities=
: [150] Power Budgeting <?>=A0 =A0 =A0 =A0 Capabilities: [160] Virtual =
Channel <?>=A0 =A0 =A0 =A0 Kernel driver in use: bnx2x=A0 =A0 =A0 =A0 K=
ernel modules: bnx2x
----------------------------------------
> Subject: Re: bnx2x kerneloops
> From: dmitry@broadcom.com
> To: carlospeon@hotmail.com
> CC: netdev@vger.kernel.org
> Date: Wed, 2 Nov 2011 13:54:05 +0200
>

> Which HW you are using?

 		 	   		  