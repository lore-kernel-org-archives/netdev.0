From: Stephen Hemminger <shemminger@osdl.org>
Subject: Iproute2: update
Date: Wed, 12 Jan 2005 12:59:03 -0800
Message-ID: <20050112125903.64d42737@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is an new version of iproute2 for testing.
http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.10-ss050112.tar.gz	

Mostly simple merges, but could have some issues.
Jamal did I get everything you sent?

[Masahide Nakamura]
	ipmonitor shows IPv6 prefix list notification
	update to iproute2 xfrm for ipv6	
	
[Stephen Hemminger]
	fix compile warnings when building 64bit system
	don't include <asm/byteorder.h>
	warning about "ip route nat" no longer supported

[Catalin(ux aka Dino) BOIE]
	fwmark in u32 filters
	
[Andi Kleen]
	netlink manual page

[Thomas Graf]
	tc testsuite

[Jamal Hadi Salim]
	iptables tc support
	mirror and redirect actions


-- 
Stephen Hemminger	<shemminger@osdl.org>
