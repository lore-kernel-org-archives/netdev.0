From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Wed, 29 Sep 2004 23:43:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16731.11413.331685.70763@robur.slu.se>
References: <20040928214722.11aef8e0.davem@davemloft.net>
	<16730.53965.503605.943263@robur.slu.se>
	<20040929125359.12a00ba7.davem@davemloft.net>
	<1096492842.2344.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steven Blake <slblake@petri-meat.com>
In-Reply-To: <1096492842.2344.57.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Steven Blake writes:

 > No routing protocols are distributing TOS-specific routes, and there is
 > no prospect of that feature ever coming back.  Why pay the cost of
 > matching TOS on every packet forwarded?

 Well you may be right but with a pluggable lookup algo we could choose
 between TOS-capable/complex and more lightweight and speedy things.

 Cheers.
						--ro
