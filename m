From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops: Process zebra, EIP is at fib_create_info+0x22b/0x580
Date: Mon, 23 Aug 2004 12:04:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1Bz4Cc-00011R-00@gondolin.me.apana.org.au>
References: <E1BynNG-0007qB-00@gondolin.me.apana.org.au>
Cc: davem@redhat.com, vrsbs@derbian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au (Herbert Xu)
In-Reply-To: <E1BynNG-0007qB-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> Do you know of any changes between 2.6.7 and 2.6.8 that might impact
> on the FIB stuff? Any locking changes?

Actually, this looks like the qdisc align bug that Patrick fixed
a week ago.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
