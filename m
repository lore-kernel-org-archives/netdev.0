From: Joy Latten <latten@austin.ibm.com>
Subject: [BUG?] IP Compression over 2 interfaces
Date: Tue, 30 Nov 2004 00:13:33 +0000 (UTC)
Message-ID: <200412011925.iB1JPsIM024625@faith.austin.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 1 Dec 2004 13:25:54 -0600
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I tried running an IP Compression stress testcase and noticed odd behaviour.
I used 2 machines with 2 ethernet cards each and a simple transport mode
configuration; sending compressed packets across each ethernet to the other machine.
I start sending packets over first interface with no problems.
But when I start sending over second interface, hardly any packets get sent.
Meanwhile, first interface is sending hundreds of packets.

My network cards are identical (ethernet pro 100).
Has anyone else noticed this?

Regards,
Joy Latten
