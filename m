From: Simon Peter <dn.tlp@gmx.net>
Subject: forcedeth received irq with unknown events
Date: Thu, 29 Apr 2004 14:30:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040429143006.4f8b5df0.dn.tlp@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there!

Since i plugged the DSL-Modem directly to my onboard nForce2 network
card (it's a Shuttle AN35-400 Mobo), i constantly get the following
messages in my syslog:

Apr 29 14:15:02 server kernel: eth0: received irq with unknown events
0x1. Please report
Apr 29 14:15:33 server last message repeated 28 times
Apr 29 14:15:55 server last message repeated 23 times

The message seems to be displaying more frequently the more traffic is
on the link.

Formerly, the nForce2 board was connected to a 100mbps switch to my LAN
and i didn't get any of these messages.

If you need any more info to get this fixed, just reply!

Great work with the driver!
Simon
