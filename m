From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Wed, 25 May 2005 16:40:45 -0700 (PDT)
Message-ID: <20050525.164045.90119936.davem@davemloft.net>
References: <20050524082021.GA31446@gondor.apana.org.au>
	<20050524.174931.46801018.yoshfuji@linux-ipv6.org>
	<20050524115914.GA697@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050524115914.GA697@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 May 2005 21:59:14 +1000

> On Tue, May 24, 2005 at 05:49:31PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > 
> > [XFRM] Call dst_check() with appropriate cookie
> > 
> > This fixes infinite loop issue with IPv6 tunnel mode.
> > 
> > Signed-off-by: Kazunori Miyazawa <kazunori@miyazawa.org>
> > Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> Looks good.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
