From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sun, 26 Dec 2004 16:45:00 +1100
Message-ID: <E1CiRDA-0004wk-00@gondolin.me.apana.org.au>
References: <20041225135650.55dca29f.davem@davemloft.net>
Cc: laforge@gnumonks.org, yoshfuji@linux-ipv6.org, pekkas@netcore.fi,
        netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20041225135650.55dca29f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> I've also discussed this with Herbert Xu a bit, and no one
> solution is really clear yet.  IPV4 has similar issues, just
> in a slightly different form.

Well I still reckon that the IPv4 behaviour is just fine as
it is.  In fact if anything we should make the IPv6 case as
similar to Ipv4 as possible.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
