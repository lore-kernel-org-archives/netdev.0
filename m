From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Wed, 22 Sep 2004 09:07:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C9tj0-0003KE-00@gondolin.me.apana.org.au>
References: <20040921210427.GB19575@kvack.org>
Cc: jchapman@katalix.com, davem@davemloft.net, netdev@oss.sgi.com,
        kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@kvack.org (Benjamin LaHaise)
In-Reply-To: <20040921210427.GB19575@kvack.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Benjamin LaHaise <bcrl@kvack.org> wrote:
>
>> - Unlikely to integrate with the new native IPSEC stuff.
> 
> L2TP over IPSEC?  Are you insane?  You'd not be able to terminate more than 
> a couple of dozen connections over it. =-)

Why not? L2TP over IPsec is the only reason I'm looking at L2TP at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
