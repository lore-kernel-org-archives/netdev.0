From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Not all tcp sockets are found by ss command (iproute2)
Date: Thu, 07 Oct 2004 18:19:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CFTUz-0007V6-00@gondolin.me.apana.org.au>
References: <4164F60C.6080807@cosmosbay.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com (Eric Dumazet)
In-Reply-To: <4164F60C.6080807@cosmosbay.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
>
> Of course, /proc/net/tcp on such machine is not an option (never 
> completes), so I cant list all connections for this machine. I really 
> *need* a working ss command.
> 
> Are they known problems ?

They are known now :) I'm working on a fix to these problems so
stay tuned.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
