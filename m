From: Stephen Hemminger <shemminger@osdl.org>
Subject: b44: timeout on initialization
Date: Thu, 13 Jan 2005 18:31:47 -0800
Message-ID: <20050113183147.0772941c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Schirmer <jolt@tuxbox.org>, "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I get this all the time on my laptop (2.6.8 - 2.6.10) even
when connected to the router
b44: eth0: BUG!  Timeout waiting for bit 00000001 of register 41c to set.

repeats about 5 times then goes away. Connection works fine.
Description is

01:0c.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX (rev 02)
        Subsystem: Fujitsu Limited.: Unknown device 123b
        Flags: bus master, fast devsel, latency 64, IRQ 11
        Memory at d0204000 (32-bit, non-prefetchable) [size=8K]
        Capabilities: [40] Power Management version 2
