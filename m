From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Probe selected algorithm only
Date: Sat, 5 Feb 2005 08:32:11 +1100
Message-ID: <20050204213211.GA16788@gondor.apana.org.au>
References: <20050121101938.GA1133@gondor.apana.org.au> <m3fz0cj9o2.fsf@igel.m5r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Andreas Schwab <schwab@suse.de>
Content-Disposition: inline
In-Reply-To: <m3fz0cj9o2.fsf@igel.m5r.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 04, 2005 at 10:29:49PM +0100, Andreas Schwab wrote:
> 
> Return the first matching entry in xfrm_get_byname instead of the first
> non-matching one.

Yes you're totally right.  Dave has already added a fix for this to
his tree.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
