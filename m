From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Unitialized queue_lock oops?
Date: Sat, 4 Jun 2005 10:34:41 +1000
Message-ID: <20050604003441.GA20471@gondor.apana.org.au>
References: <20050603232413.GA29308@linuxace.com> <E1DeLwo-0005GI-00@gondolin.me.apana.org.au> <20050604000046.GA29438@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20050604000046.GA29438@linuxace.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2005 at 05:00:46PM -0700, Phil Oester wrote:
> 
> Yes, default qdisc.  Interesting that 2.6.10 is rock solid on the same
> hardware...oh well.

Well if you do have the time feel free to keep searching back to 2.6.10.
Even though I'd say that this is most likely to turn out to be a hardware
problem, there is no telling what you might find along the way.

At least it might tell us what sort of hardware problems would result in
only networking crashes :) If this were your average hardware problem
I'd have expected to see crashes all over the place, especially under
fs/ and mm/.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
