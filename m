From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 15:10:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D1ECAA.4090509@pobox.com>
References: <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <40D1E24C.8090802@pobox.com> <20040617115156.14c946b5@dell_ss3.pdx.osdl.net> <20040617190049.GC32216@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040617190049.GC32216@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> On Thu, Jun 17, 2004 at 11:51:56AM -0700, Stephen Hemminger wrote:
> 
>>Remember the API for applications (netlink) doesn't need to be the same as
>>the driver interface (wireless_ops).  That is the whole point of having
>>a common core layer.
> 
> 
> 	Stephen : we have been there since 2001. Check the RtNetlink
> patch on my web page, it allows full access to all wireless extensions
> through netlink without having to modify a single driver.


Nod...  here's hoping others are checking out out too.

As Stephen points out, though, the driver interface redesign is separate 
from the use of netlink.

	Jeff
