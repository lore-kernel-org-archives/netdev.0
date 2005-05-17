From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 13:22:02 -0700 (PDT)
Message-ID: <20050517.132202.59028935.davem@davemloft.net>
References: <m1sm0l7jcl.fsf@muc.de>
	<OF0221F508.AD091D99-ON88257004.006D0C52-88257004.006D8293@us.ibm.com>
	<m1k6lx7gkf.fsf@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, akepner@sgi.com, jheffner@psc.edu,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <m1k6lx7gkf.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Date: Tue, 17 May 2005 22:17:36 +0200

> At least for a directly connected flat network you could get it from ARP.

So we can make this host based, and store that "arp RTT" thing in the
inetpeer cache.  :-)
