From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Wed, 8 Sep 2004 22:08:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908220802.1c25b806.davem@davemloft.net>
References: <20040909034508.GA19547@gondor.apana.org.au>
	<20040908214023.08dec350.davem@davemloft.net>
	<20040909044336.GA19999@gondor.apana.org.au>
	<20040908214926.51b56a66.davem@davemloft.net>
	<20040909045415.GA20079@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040909045415.GA20079@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 14:54:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > I would expect a change for that to occur in net/ipv4/ipip.c
> > or similar. :)
> 
> OK, I'll take a look at this.  I presume that the TOS options
> in ip6tunnel.c is to your liking?

It looks fine.
