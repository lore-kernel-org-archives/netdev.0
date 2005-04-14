From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] Replace bogus instances of inet->recverr
Date: Thu, 14 Apr 2005 22:21:24 +0900 (JST)
Message-ID: <20050414.222124.27105970.yoshfuji@linux-ipv6.org>
References: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com>
	<E1DM3QD-00045e-00@gondolin.me.apana.org.au>
	<20050414123423.GA16334@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, davem@davemloft.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, herbert@gondor.apana.org.au
In-Reply-To: <20050414123423.GA16334@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050414123423.GA16334@gondor.apana.org.au> (at Thu, 14 Apr 2005 22:34:23 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> While looking at this problem I noticed that IPv6 was sometimes
> looking at inet->recverr which is bogus.  Here is a patch to
> correct that and use np->recverr.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

ok, agreed.

Acked-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

--yoshfuji
