From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Wed, 17 Jun 2009 08:26:16 -0400
Message-ID: <20090617122616.GB2791@tuxdriver.com>
References: <1244889678.13033.6.camel@johannes.local> <1244896094.13033.8.camel@johannes.local> <20090616111842.GG3521@psychotron.englab.brq.redhat.com> <1245151771.9256.3.camel@johannes.local> <20090616123808.GK3521@psychotron.englab.brq.redhat.com> <1245193788.21287.66.camel@johannes.local> <20090617072100.GA3492@psychotron.englab.brq.redhat.com> <1245231024.19769.0.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	davem <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1245231024.19769.0.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 17, 2009 at 11:30:24AM +0200, Johannes Berg wrote:
> On Wed, 2009-06-17 at 09:21 +0200, Jiri Pirko wrote:
> 
> > >I guess we could stick this one into wireless-testing, and then take it
> > >out again once your patch hits the tree and offers me similar API for
> > >list_head based multicast lists?
> > 
> > Or wait, I hope the patch will be ready in week tops.
> 
> Yeah, that's fine, I'll ask people to throw in the simple export patch
> for testing. Thanks for considering! Please disregard my work on
> mac80211, I'll rebase over your work.

If you need Jiri's patch in wireless-testing I can make arrangements
to cherry-pick it.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
