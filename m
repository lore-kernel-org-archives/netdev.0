From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 17:52:10 -0700 (PDT)
Message-ID: <20050517.175210.41633462.davem@davemloft.net>
References: <20050517232556.GA26846@gondor.apana.org.au>
	<m11x85762p.fsf@muc.de>
	<20050518000955.GA27212@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, dlstevens@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050518000955.GA27212@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 10:09:55 +1000

> On Wed, May 18, 2005 at 02:04:14AM +0200, Andi Kleen wrote:
> > Herbert Xu <herbert@gondor.apana.org.au> writes:
> > It will, you just need enough other hosts to thrash inetpeer. How many
> > you need depends on your available memory.
> 
> Even when the cache entry is deleted, Linux will allocate an ID randomly
> so the chance of what was stated above occuring is very small.

Yes, that's right.  Andi just doesn't like inetpeer, so let's just
move along and accept that. :-)
