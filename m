From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Mon, 27 Sep 2004 21:59:56 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBuAe-00011H-00@gondolin.me.apana.org.au>
References: <16727.65341.747293.986870@robur.slu.se>
Cc: davem@davemloft.net, ja@ssi.bg, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <16727.65341.747293.986870@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson <Robert.Olsson@data.slu.se> wrote:
> 
> I'll guess struct fib_alias should not be defined in fib_hash.c to 
> support pluggable lookup algorithms.

Should one turn up then we can move it out :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
