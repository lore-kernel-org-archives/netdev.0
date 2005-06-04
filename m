From: Phil Oester <kernel@linuxace.com>
Subject: Re: Unitialized queue_lock oops?
Date: Fri, 3 Jun 2005 17:00:46 -0700
Message-ID: <20050604000046.GA29438@linuxace.com>
References: <20050603232413.GA29308@linuxace.com> <E1DeLwo-0005GI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DeLwo-0005GI-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 09:51:30AM +1000, Herbert Xu wrote:
> I'd say that either you're using a dodgy qdisc, or your hardware is
> just stuffed.  That is, if you are using the default qdisc, you should
> start looking at replacing pieces of the hardware to find the problem.

Yes, default qdisc.  Interesting that 2.6.10 is rock solid on the same
hardware...oh well.

Phil
