From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: way of figuring out total number of retransmitted packets on a TCP socket?
Date: Wed, 20 Oct 2004 15:01:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020130134.GC24757@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm looking for a way of counting the total number of retransmitted packets
sent on a TCP connection.  I tried querying TCP_INFO:tcpi_retransmits, but
that seems to be not the metric I'm looking for.

Anyone got any ideas?  (Apart from using tcpdump+tcptrace.)


cheers,
Lennert
