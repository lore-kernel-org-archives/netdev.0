From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: Fri, 23 Jul 2004 21:42:40 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723.214240.76745170.yoshfuji@linux-ipv6.org>
References: <1090612669.1218.47.camel@jzny.localdomain>
	<20040723135945.7f50b02c.davem@redhat.com>
	<1090630154.1134.6.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, arekm@pld-linux.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org, hadi@znyx.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com, davem@redhat.com
In-Reply-To: <1090630154.1134.6.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1090630154.1134.6.camel@jzny.localdomain> (at 23 Jul 2004 20:49:15 -0400), Jamal Hadi Salim <hadi@znyx.com> says:

> I will take care of it next week when i get back. 
> If 2.6.8 is coming out before end of next week, i would suggest undoing
> Stephens patch.

I've talked about this with Jamal.

I believe it is very important to maintain th original (or 
traditional) ABI, which has been used in -2.6.7(?).

So, I'd rather say, let's remove (or disable) whole thing 
until we find the way to avoid breaking ABIs.

--yoshfuji
