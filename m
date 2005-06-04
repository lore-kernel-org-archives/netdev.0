From: Phil Oester <kernel@linuxace.com>
Subject: Re: Unitialized queue_lock oops?
Date: Fri, 3 Jun 2005 17:38:35 -0700
Message-ID: <20050604003835.GA29635@linuxace.com>
References: <20050603232413.GA29308@linuxace.com> <E1DeLwo-0005GI-00@gondolin.me.apana.org.au> <20050604000046.GA29438@linuxace.com> <20050604003441.GA20471@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050604003441.GA20471@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 10:34:41AM +1000, Herbert Xu wrote:
> On Fri, Jun 03, 2005 at 05:00:46PM -0700, Phil Oester wrote:
> > 
> > Yes, default qdisc.  Interesting that 2.6.10 is rock solid on the same
> > hardware...oh well.
> 
> Well if you do have the time feel free to keep searching back to 2.6.10.
> Even though I'd say that this is most likely to turn out to be a hardware
> problem, there is no telling what you might find along the way.
> 
> At least it might tell us what sort of hardware problems would result in
> only networking crashes :) If this were your average hardware problem
> I'd have expected to see crashes all over the place, especially under
> fs/ and mm/.

Ok, how bout next week I adjust OSPF costs to make my secondary firewall
primary, and see if I still have problems?  At least then we can put the
hardware problem theory behind us...

Phil
