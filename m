From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch2: del/get byid
Date: Thu, 28 Apr 2005 12:42:53 +1000
Message-ID: <20050428024253.GA23695@gondor.apana.org.au>
References: <1114654284.7663.50.camel@localhost.localdomain> <20050428021426.GA23415@gondor.apana.org.au> <1114655014.7663.61.camel@localhost.localdomain> <20050428022549.GA23556@gondor.apana.org.au> <1114655980.7663.76.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114655980.7663.76.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 10:39:40PM -0400, jamal wrote:
> 
> That would never work without those two patches.

Sorry, but you've just broken the policy timer.  This is the
other use of index.  It's a sneaky way of carrying around dir
in the policy without actually specifying it :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
