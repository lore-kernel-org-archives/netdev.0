From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Wed, 27 Apr 2005 22:55:32 -0400
Message-ID: <1114656932.7663.88.camel@localhost.localdomain>
References: <1114654284.7663.50.camel@localhost.localdomain>
	 <20050428021426.GA23415@gondor.apana.org.au>
	 <1114655014.7663.61.camel@localhost.localdomain>
	 <20050428022549.GA23556@gondor.apana.org.au>
	 <1114655980.7663.76.camel@localhost.localdomain>
	 <20050428024253.GA23695@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428024253.GA23695@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 12:42 +1000, Herbert Xu wrote:
> On Wed, Apr 27, 2005 at 10:39:40PM -0400, jamal wrote:
> > 
> > That would never work without those two patches.
> 
> Sorry, but you've just broken the policy timer.  This is the
> other use of index.  It's a sneaky way of carrying around dir
> in the policy without actually specifying it :)

Dang ;-> Thats some abuse ;->
It would probably be easy to steal 2 bits off the flags instead, no?
Its not like they are being highly utilized.

cheers,
jamal
