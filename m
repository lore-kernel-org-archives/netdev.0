From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Re: Daughterboard Jetway JAD3RTLANG with three RTL-8110SC/8169SC
 Gigabit Ethernet is curious
Date: Thu, 01 Dec 2011 17:41:59 +0100
Message-ID: <jb8aon$5eo$1@dough.gmane.org>
References: <jb0d7u$bbb$1@dough.gmane.org> <201111291012.25426.carsten@wolffcarsten.de> <4ED4E946.40209@gmx.de> <20111129230404.GB11127@electric-eye.fr.zoreil.com> <jb4m9i$j5c$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:59140 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755251Ab1LAQmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 11:42:15 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RW9i9-0001xe-3X
	for netdev@vger.kernel.org; Thu, 01 Dec 2011 17:42:13 +0100
Received: from dslb-092-076-245-241.pools.arcor-ip.net ([92.76.245.241])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 17:42:13 +0100
Received: from feldmann_markus by dslb-092-076-245-241.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 17:42:13 +0100
In-Reply-To: <jb4m9i$j5c$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, i posted the output from my client :-)

Here comes the one from my server:
> 04:04.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
> 	Subsystem: Jetway Information Co., Ltd. Device 10ec
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
> 	Interrupt: pin A routed to IRQ 10
> 	Region 0: I/O ports at de00 [size=256]
> 	Region 1: Memory at fdbff000 (32-bit, non-prefetchable) [size=256]
> 	Expansion ROM at fdbc0000 [disabled] [size=128K]
> 	Capabilities: [dc] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: r8169
>
> 04:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
> 	Subsystem: Jetway Information Co., Ltd. Device 10ec
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: I/O ports at dc00 [size=256]
> 	Region 1: Memory at fdbfe000 (32-bit, non-prefetchable) [size=256]
> 	Expansion ROM at fda00000 [disabled] [size=128K]
> 	Capabilities: [dc] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: r8169
>
> 04:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
> 	Subsystem: Jetway Information Co., Ltd. Device 10ec
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
> 	Interrupt: pin A routed to IRQ 5
> 	Region 0: I/O ports at da00 [size=256]
> 	Region 1: Memory at fdbfd000 (32-bit, non-prefetchable) [size=256]
> 	Expansion ROM at fda20000 [disabled] [size=128K]
> 	Capabilities: [dc] Power Management version 2
> 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 	Kernel driver in use: r8169

regards Markus
