From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 21:33:04 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202103304.GA25658@gondor.apana.org.au>
References: <20031201201651.GA20194@gondor.apana.org.au> <20031201204700.GA20349@gondor.apana.org.au> <20031201135154.6906454c.davem@redhat.com> <20031201220509.GA20827@gondor.apana.org.au> <20031201142131.5da50a07.davem@redhat.com> <20031201152215.522c2447.davem@redhat.com> <20031202101025.GA25422@gondor.apana.org.au> <20031202022733.43cf693e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031202022733.43cf693e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 02, 2003 at 02:27:33AM -0800, David S. Miller wrote:
> 
> That behavior of glibc is incorrect, I know about it, and I explained
> all this to Uli Drepper some time ago and he fixed it.

Cool.  I can confirm that this is definitely fixed with a more recent
glibc.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
