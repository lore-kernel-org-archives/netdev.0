From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: design for TSO performance fix
Date: Sat, 29 Jan 2005 21:12:45 +1100
Message-ID: <20050129101245.GB13584@gondor.apana.org.au>
References: <20050127163146.33b01e95.davem@davemloft.net> <E1CuKzJ-0001mY-00@gondolin.me.apana.org.au> <20050127211940.31f97ed3.davem@davemloft.net> <20050128054441.GA8260@gondor.apana.org.au> <20050128112838.21e53b6c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050128112838.21e53b6c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 28, 2005 at 11:28:38AM -0800, David S. Miller wrote:
> 
> TSO packets only exist in the tcp_transmit_skb() path,
> nothing else in the stack sees them.

Cool, that should be really good then.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
