From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Fix ECN encapsulation for IPv6
Date: Wed, 8 Sep 2004 21:38:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908213855.084f53e2.davem@davemloft.net>
References: <20040909023454.GA15407@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040909023454.GA15407@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 12:34:54 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> While doing the ECN patch I discovered that IPsec on IPv6 wasn't
> encapsulating the ECN correctly.  This patch fixes that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

Please use my davem@davemloft.net email address in the future,
as that is what I'd like people to use to contact me.  This is
what is listed in CREDITS and MAINTAINERS as well.

Thanks.
