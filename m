From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NETLINK] introduce netlink bucket
Date: Wed, 03 Nov 2004 09:16:13 +1100
Message-ID: <E1CP6wn-0003VF-00@gondolin.me.apana.org.au>
References: <4187FF18.5050608@eurodev.net>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pablo@eurodev.net (Pablo Neira)
In-Reply-To: <4187FF18.5050608@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira <pablo@eurodev.net> wrote:
> 
> This patch introduces the netlink bucket struct, it joins three arrays 
> into an array of netlink bucket.

Please hold onto any work involving netlink itself, there are some
pending patches in that area right now.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
