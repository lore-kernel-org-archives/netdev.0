From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-02-23
Date: Thu, 26 Feb 2009 11:13:40 -0500
Message-ID: <20090226161340.GA4430@tuxdriver.com>
References: <20090223192659.GB3553@tuxdriver.com> <1235457113.4455.89.camel@johannes.local> <20090224.235510.30497146.davem@davemloft.net> <1235637360.29050.16.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1235637360.29050.16.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 26, 2009 at 12:36:00AM -0800, Johannes Berg wrote:
> On Tue, 2009-02-24 at 23:55 -0800, David Miller wrote:
> > From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> > Date: Mon, 23 Feb 2009 22:31:53 -0800
> > 
> > > On Mon, 2009-02-23 at 14:26 -0500, John W. Linville wrote:
> > > 
> > > > Johannes Berg (10):
> > > >       mac80211: disallow moving netns
> > > >       mac80211: fix aggregation for hardware with ampdu queues
> > > >       mac80211: split IBSS/managed code
> > > >       genetlink: introduce pre/post methods
> > > 
> > > Hold off on this please, the genetlink patch here introduced a problem
> > > with locking and I'm going to rework/fix that.
> > 
> > Ok.
> > 
> > In fact it's better this way, since now John can send me the pull
> > request after the net-2.6 --> net-next-2.6 merge conflicts are
> > resolved.
> 
> Now I just have to get around to fixing it, it's proving to be harder
> than I thought, and I don't have much time right now.

I suppose I could just drop that one.  IIRC there was another patch
from you that depended upon that one as well?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
