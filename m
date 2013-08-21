From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: ADSL/ATM linklayer tc shaping regression fix commits
	for stable
Date: Wed, 21 Aug 2013 11:20:23 -0700 (PDT)
Message-ID: <20130821.112023.744177612387539958.davem@davemloft.net>
References: <20130820132629.51618797@redhat.com>
	<20130820151650.GA18016@kroah.com>
	<20130821140350.2b953007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
To: brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
In-Reply-To: <20130821140350.2b953007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.bufferbloat.net/options/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/bloat>
List-Post: <mailto:bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
List-Help: <mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=subscribe>
Sender: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
Errors-To: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 21 Aug 2013 14:03:50 +0200

> 
> On Tue, 20 Aug 2013 08:16:50 -0700
> Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
>> On Tue, Aug 20, 2013 at 01:26:29PM +0200, Jesper Dangaard Brouer wrote:
> [...]
>  
>> If there are issues with 3.10, that's a different story.
>> 
>> > Refactor improvements (v3.11-rc1):
>> >  commit 130d3d68b52 (net_sched: psched_ratecfg_precompute() improvements)
> 
> Needed because it fixes the accuracy of the rate calc.
> 
>> > The linklayer ATM/ADSL fix, reached 3.11-rc6:
>> >  commit 8a8e3d84b17 (net_sched: restore "linklayer atm" handling)
> 
> Needed because we broke userspace interface.
> 
>> David sends me the networking patches for the stable tree, and if he
>> thinks these are applicable, then I'll take them.
> 
> DaveM, please?  What do you want me to do, submit this req/patches somehow?
> 
> (Can see that is not currently on your stable queue via:
> http://patchwork.ozlabs.org/bundle/davem/stable/?state=*)

I'll put it there, you just have to formally ask me to do it that's
all.

Asking Greg to do it directly is a complete waste of time. :-)
