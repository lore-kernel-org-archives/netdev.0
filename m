From: Jon Smirl <jonsmirl@gmail.com>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Fri, 17 Sep 2004 20:59:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <9e4733910409171759242349f0@mail.gmail.com>
References: <9e47339104091717215e9be08b@mail.gmail.com>
	 <E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
Reply-To: Jon Smirl <jonsmirl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, david@gibson.dropbear.id.au, akpm@osdl.org,
        trivial@rustcorp.com.au, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C8T4t-0006ug-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have verified that compiling the drivers in avoids the problem. 

I'll boot again and get more of the error message. It's not making it
to the logs so I am copying it by hand from the screen.


On Sat, 18 Sep 2004 10:27:47 +1000, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> Jon Smirl <jonsmirl@gmail.com> wrote:
> > I'm still OOPsing at boot in fib_disable_ip+21 from
> > fib_netdev_event+63. Both e1000 and tg3 are effected. I have current
> > linus bk as of time of this message.
> 
> Please post the complete error message.
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 



-- 
Jon Smirl
jonsmirl@gmail.com
