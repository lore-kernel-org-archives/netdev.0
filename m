From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Ipsec-tools-devel] ipv4/ipv6 forwarding check
Date: Fri, 29 Oct 2004 17:23:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CNR73-0007X6-00@gondolin.me.apana.org.au>
References: <4181EBC3.3020507@gmc.lt>
Cc: latten@austin.ibm.com, ipsec-tools-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: a.kasparas@gmc.lt (Aidas Kasparas)
In-Reply-To: <4181EBC3.3020507@gmc.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Aidas Kasparas <a.kasparas@gmc.lt> wrote:
> 
>        Meanwhile, I would like to recomend to abstain from upgrading to 
> anything above 2.6.9.

Doesn't sound like a good idea as that's a massive security hole.

Racoon with a pre-2.6.9 kernel will allow source addresses to come
through the IPsec tunnel even if the violate IPsec policies.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
