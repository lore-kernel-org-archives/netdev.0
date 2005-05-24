From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 21:59:14 +1000
Message-ID: <20050524115914.GA697@gondor.apana.org.au>
References: <20050524.124919.00464304.yoshfuji@linux-ipv6.org> <20050524082021.GA31446@gondor.apana.org.au> <20050524.174931.46801018.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050524.174931.46801018.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 05:49:31PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> [XFRM] Call dst_check() with appropriate cookie
> 
> This fixes infinite loop issue with IPv6 tunnel mode.
> 
> Signed-off-by: Kazunori Miyazawa <kazunori@miyazawa.org>
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Looks good.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
