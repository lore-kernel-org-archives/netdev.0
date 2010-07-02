From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2010-07-01
Date: Fri, 2 Jul 2010 10:08:05 -0400
Message-ID: <20100702140805.GA2381@tuxdriver.com>
References: <20100701181526.GA2356@tuxdriver.com>
 <20100701.173550.172604489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100701.173550.172604489.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 01, 2010 at 05:35:50PM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Thu, 1 Jul 2010 14:15:27 -0400
> 
> > Two weeks since the last request, plenty of new stuff intended for
> > 2.6.36...
> > 
> > Included are the usual bunch of driver updates, including a big
> > dump from the rt2x00 team.  This also includes cfg80211 support
> > for libertas, a flurry of (mostly trivial) stuff from me, and a
> > wireless-2.6 pull to resolve some patch dependencies.
> > 
> > Please let me know if there are problems!
> 
> This failed to pull cleanly, I got a conflict in
> drivers/net/wireless/libertas/host.h  It was the
> usual "__packed" vs. "__attribute__((packed))" thing.
> 
> I resolved it but I wonder if this happened because you
> did the wireless-2.6 --> wireless-next-2.6 merge here.

Sorry, Dave!  I probably should have done 'for-davem' branch for you.
Thanks for resolving it!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
