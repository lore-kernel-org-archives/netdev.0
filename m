From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Fix ipv6_ifa_notify race
Date: Fri, 19 Nov 2004 11:33:44 -0500 (EST)
Message-ID: <20041119.113344.48190868.yoshfuji@linux-ipv6.org>
References: <4197AC20.6020707@pobox.com>
	<E1CTR5h-0006ac-00@gondolin.me.apana.org.au>
	<20041119094924.GA3726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, acme@conectiva.com.br,
        jgarzik@pobox.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20041119094924.GA3726@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041119094924.GA3726@gondor.apana.org.au> (at Fri, 19 Nov 2004 20:49:24 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> May I ask this question again: Is it possible to move some of
> this complexity to user-space?

I strongly believe it should be implemented in kernel.

--yoshfuji
