From: Felix Radensky <felix@allot.com>
Subject: hw tcp v4 csum failed on 2.4.23-rc2
Date: Thu, 20 Nov 2003 15:50:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBCC693.7070404@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I keep getting tons of this messages with 2.4.23-rc2
and e100 driver:

memory : df576280
memory : df576200
memory : df576180
memory : df576100
memory : dca33f80
hw tcp v4 csum failed
hw tcp v4 csum failed
....

Is it a hardware problem or e100 problem ?

The hardware is Asus MB with Pentum 4 2.4GHz

00:00.0 Host bridge: Intel Corp. 82865G/PE/P Processor to I/O Controller 
(rev 02)
00:02.0 VGA compatible controller: Intel Corp. 82865G Integrated 
Graphics Device (rev 02)
00:1d.0 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.1 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.2 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.3 USB Controller: Intel Corp. 82801EB USB (rev 02)
00:1d.7 USB Controller: Intel Corp. 82801EB USB2 (rev 02)
00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB PCI Bridge (rev c2)
00:1f.0 ISA bridge: Intel Corp. 82801EB LPC Interface Controller (rev 02)
00:1f.1 IDE interface: Intel Corp. 82801EB Ultra ATA Storage Controller 
(rev 02)
00:1f.3 SMBus: Intel Corp. 82801EB SMBus Controller (rev 02)
00:1f.5 Multimedia audio controller: Intel Corp. 82801EB AC'97 Audio 
Controller (rev 02)
01:08.0 Ethernet controller: Intel Corp.: Unknown device 1050 (rev 02)

Thanks.

Felix.
