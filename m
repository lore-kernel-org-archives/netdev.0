From: Stephen Hemminger <shemminger@osdl.org>
Subject: 2.6.0-test7-netx1
Date: Thu, 9 Oct 2003 15:53:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031009155302.4f2fe835.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


http://developer.osdl.org/shemminger/netx/2.6/2.6.0-test7/2.6.0-test7-netx1/

This is the first of a hopefuly continuing series of network related experimental 
kernels.  This patch set will contain things like new network drivers, protocols 
and infrastructure changes that are not related to the stability goal
for the mainline kernel tree.

The initial installment includes:
    * ISA device probing changes
    * SimTel 4200 IRDA dongle (originally by Paul Stewart)
    * IRDA hashbin cleanup
    * WAN device bugfixes and cleanups
    * TCP Vegas (from Dave Miller)

I am interested in receiving patches for network related stuff
like:
    * drivers for new hardware
    * rework of old drives (will put in new e100 driver next time).
    * TCP tuning options
    * support for 1000's of network devices
    * network async i/o
    * per cpu network statistics




    
