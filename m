From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-11-28
Date: Tue, 29 Nov 2011 08:42:43 -0500
Message-ID: <20111129134243.GB2705@tuxdriver.com>
References: <20111128200221.GD2681@tuxdriver.com>
 <1322554972.4110.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1322554972.4110.0.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2011 at 09:22:52AM +0100, Johannes Berg wrote:
> On Mon, 2011-11-28 at 15:02 -0500, John W. Linville wrote:
> 
> > Johannes Berg (12):
> 
> >       mac80211: use skb list for fragments
> >       mac80211: move fragment flag adjustment
> >       mac80211: make TX LED handling independent of fragmentation
> >       mac80211: transmit fragment list to drivers
> 
> Since you included these patches, can you please pick up "mac80211: fix
> TX warning" relatively quickly? It fixes a harmless but possibly
> recurring WARN_ON in this code.

It's already in wireless-next. :-)

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
