From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Move local_bh_disable back in dev_queue_xmit
Date: Thu, 04 Nov 2004 08:09:16 +1100
Message-ID: <E1CPSNY-0006fe-00@gondolin.me.apana.org.au>
References: <4188EFD1.4050909@tpack.net>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, mingo@elte.hu,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tommy.christensen@tpack.net (Tommy Christensen)
In-Reply-To: <4188EFD1.4050909@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen <tommy.christensen@tpack.net> wrote:
>
> No, this breaks the normal return path.
> 
> How about this instead?

Thanks, your patch looks much better.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
