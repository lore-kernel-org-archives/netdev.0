From: Peter Buckingham <peter@pantasys.com>
Subject: Re: Mystery packet killing tg3
Date: Thu, 05 May 2005 10:38:27 -0700
Message-ID: <427A5A13.1080402@pantasys.com>
References: <20050502162405.65dfb4a9@localhost.localdomain>	<20050502200251.38271b61.davem@davemloft.net>	<m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com>	<20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com> <427A58A0.3080309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <427A58A0.3080309@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> IIRC the HP Itanium2 workstations (zx2000, zx6000) have a 32-bit Intel 
> (e1000) GbE on them.  I have an idea what the name of the chip was, but 
> will defer to any and all Intel types on the list :)

this is the one we're using. in the next generation of our system we'll 
definitely be using a 64bit part...

peter

0000:05:07.0 Ethernet controller: Intel Corp. 82541GI/PI Gigabit 
Ethernet Controller (rev 05)
         Subsystem: Giga-byte Technology: Unknown device 3000
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 64 (63750ns min), cache line size 10
         Interrupt: pin A routed to IRQ 201
         Region 0: Memory at beda0000 (32-bit, non-prefetchable)
         Region 2: I/O ports at fc00 [size=64]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [e4] PCI-X non-bridge device.
                 Command: DPERE- ERO+ RBC=0 OST=0
                 Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, 
DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-
