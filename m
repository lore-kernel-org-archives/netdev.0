From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Thu, 9 Sep 2004 14:43:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909044336.GA19999@gondor.apana.org.au>
References: <20040909034508.GA19547@gondor.apana.org.au> <20040908214023.08dec350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040908214023.08dec350.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2004 at 09:40:23PM -0700, David S. Miller wrote:
> 
> How are those TTL encap fixes coming along? ;-)

It went so well that you've already merged it :)

It's the last change on net/ipv*/xfrm*_output.c.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
