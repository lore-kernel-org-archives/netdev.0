From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] Modularise xfrm_tunnel
Date: Fri, 20 Aug 2004 08:03:42 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819220342.GA19894@gondor.apana.org.au>
References: <20040819113841.GA13872@gondor.apana.org.au> <20040819114050.GA16049@gondor.apana.org.au> <20040819114359.GA16189@gondor.apana.org.au> <20040819072525.430f00bd.davem@redhat.com> <20040819213117.GA19625@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040819213117.GA19625@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 20, 2004 at 07:31:17AM +1000, herbert wrote:
> On Thu, Aug 19, 2004 at 07:25:25AM -0700, David S. Miller wrote:
> > 
> > I suppose you're making your way towards proper TOS tunnel handling
> > and the other fixes we spoke of?
> 
> The TTL fixes? Yes.

I'm also working on a couple of other small things:

* ECN updates
* IPComp per-cpu scratch/tfm
* Check sequence number in ADD_SA/ALLOC_SPI
* pskb rollback

After that I'd like to look at the MTU stuff.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
