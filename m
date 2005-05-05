From: John Heffner <jheffner@psc.edu>
Subject: Re: Mystery packet killing tg3
Date: Thu, 5 May 2005 13:45:35 -0400
Message-ID: <200505051345.35455.jheffner@psc.edu>
References: <20050502162405.65dfb4a9@localhost.localdomain> <427A5363.2080703@pantasys.com> <427A58A0.3080309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <427A58A0.3080309@hp.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 05 May 2005 01:32 pm, Rick Jones wrote:
> Peter Buckingham wrote:
> > Andi Kleen wrote:
> >> "32bit e1000"? How did you get such a beast? AFAIK all e1000s are 64bit
> >> address capable. Please supply a full boot log without iommu=force and
> >> describe what happens exactly.
> >
> > that was my initial impression too :-(
>
> IIRC the HP Itanium2 workstations (zx2000, zx6000) have a 32-bit Intel
> (e1000) GbE on them.  I have an idea what the name of the chip was, but
> will defer to any and all Intel types on the list :)
>
> rick jones

>From a zx2000:

0000:a0:03.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet 
Controller (rev 02)
        Subsystem: Hewlett-Packard Company: Unknown device 1274
        Flags: bus master, 66MHz, medium devsel, latency 128, IRQ 56
        Memory at 00000000d0000000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at a080 [size=64]
        Capabilities: [dc] Power Management version 2
        Capabilities: [e4] PCI-X non-bridge device.
        Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 
Enable-

  -John
