From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 17:16:36 +1000
Message-ID: <E1DaTeW-00085B-00@gondolin.me.apana.org.au>
References: <20050524.124919.00464304.yoshfuji@linux-ipv6.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20050524.124919.00464304.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> From: Kazunori Miyazawa <kazunori@miyazawa.org>
> 
> [XFRM] Call dst_check() with appropriate cookie.
>
> This fixes infinite loop issue with IPv6 tunnel mode.

Can someone please tell me where this infinite loop is?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
