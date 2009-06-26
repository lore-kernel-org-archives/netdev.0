From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 0/3] wireless extensions improvements
Date: Fri, 26 Jun 2009 07:46:43 +0200
Message-ID: <20090626054642.GA4911@tuxdriver.com>
References: <20090624113447.441667549@sipsolutions.net> <20090625.161817.112930127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090625.161817.112930127.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 25, 2009 at 04:18:17PM -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Wed, 24 Jun 2009 13:34:47 +0200
> 
> > This series contains three improvements to wireless
> > extensions:
> >  1) make them network namespace aware, as discussed
> >     previously
> >  2) optimise the event sending code and fix a small
> >     heap information leak
> >  3) do some generic work and make it possible to send
> >     compat netlink events, and make wext do this
> > 
> > Because the third patch depends on the first two (it
> > could be made not to, if you wish) but touches generic
> > networking stuff, I'd like to have all of these included
> > in net-next instead of John's wireless tree, all the
> > other wireless work can be done independently of these.
> 
> These changes look fine to me, so I'll likely put them into
> net-next-2.6 as soon as I open that up.

ACK

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
