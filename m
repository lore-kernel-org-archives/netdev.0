From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] skbuff: remove old NET_CALLER macro
Date: Wed, 20 Apr 2005 10:15:34 +1000
Message-ID: <20050420001534.GA27425@gondor.apana.org.au>
References: <20050419174458.0ae804f3@localhost.localdomain> <E1DNnit-0001Qz-00@gondolin.me.apana.org.au> <20050419113500.0d10c9e1.davem@davemloft.net> <20050420100457.2444512d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050420100457.2444512d@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 20, 2005 at 10:04:57AM +1000, Stephen Hemminger wrote:
> Here is a revised alternative that uses BUG_ON/WARN_ON to eliminate
> NET_CALLER.

Looks good.  Thanks Stephen.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
