From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Mon, 27 Sep 2004 12:06:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927120629.25646b4b.davem@davemloft.net>
References: <Pine.LNX.4.58.0409261611230.8973@u.domain.uli>
	<E1CBgUG-0001GH-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBgUG-0001GH-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 07:23:16 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > [-- text/plain, encoding base64, charset: US-ASCII, 28 lines, name: fib_ins3.diff --]
> > [-- Description: fib_alias ordered by TOS --]
> > 
> > diff -ur v2.6.9-rc2-bk10/linux/net/ipv4/fib_hash.c linux/net/ipv4/fib_hash.c
> > --- v2.6.9-rc2-bk10/linux/net/ipv4/fib_hash.c   2004-09-26 16:52:11.000000000 +0300
> 
> Looks good.

To me too, thanks for describing all of this and for the
test scripts Julian.

Patch applied, thanks.
