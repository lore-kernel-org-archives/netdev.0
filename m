From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Super TSO v3
Date: Tue, 24 May 2005 07:34:38 +1000
Message-ID: <E1DaKZK-0006Qv-00@gondolin.me.apana.org.au>
References: <20050523.121943.78708600.davem@davemloft.net>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050523.121943.78708600.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> I discoevered a performance anomaly with Linux receivers,
> cause by enormous stretch ACK generation, which you'll need
> to fix if you want to test this patch against Linux receivers.

Are there non-Linux systems that have the same receive issue?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
