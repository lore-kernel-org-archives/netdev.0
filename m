From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Sat, 18 Sep 2004 10:27:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
References: <9e47339104091717215e9be08b@mail.gmail.com>
Cc: davem@davemloft.net, david@gibson.dropbear.id.au, akpm@osdl.org,
        trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Smirl <jonsmirl@gmail.com>
In-Reply-To: <9e47339104091717215e9be08b@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Smirl <jonsmirl@gmail.com> wrote:
> I'm still OOPsing at boot in fib_disable_ip+21 from
> fib_netdev_event+63. Both e1000 and tg3 are effected. I have current
> linus bk as of time of this message.

Please post the complete error message.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
