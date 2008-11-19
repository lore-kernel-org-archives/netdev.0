From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-11-18
Date: Tue, 18 Nov 2008 20:54:54 -0500
Message-ID: <20081119015453.GA10311@tuxdriver.com>
References: <20081119000719.GA19756@tuxdriver.com> <1227058418.4014.99.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1227058418.4014.99.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2008 at 02:33:38AM +0100, Johannes Berg wrote:
> > and a final one fixes some mysterious DMA alignment problems
> > that have been plaguing iwlwifi for some time.
> 
> 
> > The following changes since commit 5f9021cfdc3524a4c5e3d7ae2d049eb7adcd6776:
> >   Johannes Berg (1):
> >         rtnetlink: propagate error from dev_change_flags in do_setlink()
> 
> heh.
> 
> >      iwlagn: fix RX skb alignment
> 
> So Luis pointed out a bug in that, it might be useful to squish in this
> patch: http://marc.info/?l=linux-wireless&m=122705425425763&w=2
> 
> (also below for reference)
> 
> But we can also just add it on top, whichever way you prefer.

I'll get it in the next run, soon.

John
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
