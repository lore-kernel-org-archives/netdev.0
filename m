From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 21:43:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBtvC-0000yM-00@gondolin.me.apana.org.au>
References: <20040925005623.2faf8faf.davem@davemloft.net>
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040925005623.2faf8faf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> 2) Tim Gardner's change to smooth out periodic neighbour GC.

I think tbl->gc_interval can be killed altogether now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
