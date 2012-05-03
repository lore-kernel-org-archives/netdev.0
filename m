From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Thu, 3 May 2012 11:14:18 -0400
Message-ID: <20120503151418.GJ9285@tuxdriver.com>
References: <1336017985.12425.9.camel@edumazet-glaptop>
 <4FA21087.1080801@gmail.com>
 <1336022373.12425.24.camel@edumazet-glaptop>
 <20120503.012502.44731688706812861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120503.012502.44731688706812861.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 03, 2012 at 01:25:02AM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 03 May 2012 07:19:33 +0200
> 
> > My last patch against iwlwifi is still waiting to make its way into
> > official tree.
> > 
> > http://www.spinics.net/lists/netdev/msg192629.html
> 
> John, please rectify this situation.
> 
> The Intel Wireless folks said they would test it, but that was more
> than a month ago.
> 
> It's not acceptable to let bug fixes rot for that long, I don't care
> what their special internal testing procedure is.
> 
> If they give you further pushback, please just ignore them and apply
> Eric's fix directly.
> 
> Thank you.

I imagine that this somehow got lost in the shuffle during the
merge window.  That doesn't excuse it, of course.

It has waited long enough already, so I'll just go ahead and take it.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
