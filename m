From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH/RFC] mac80211: convert to %pM away from print_mac
Date: Mon, 27 Oct 2008 19:25:19 -0400
Message-ID: <20081027232518.GK20389@tuxdriver.com>
References: <1224892243.3919.32.camel@johannes.berg> <20081027.155243.206513005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081027.155243.206513005.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 27, 2008 at 03:52:43PM -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Sat, 25 Oct 2008 01:50:43 +0200
> 
> > Also remove a few stray DECLARE_MAC_BUF that were no longer
> > used at all.
> > 
> > Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> > ---
> > Not sure this will apply to your tree, I prepared it against John's tree
> > which might have more things. If you put the previous patch in, I
> > suppose John _could_ put it into his tree, but then he'd have to pull in
> > yours which he normally doesn't... No idea. I can also just postpone
> > this?
> 
> I munged this to apply to my tree, the only conflicts were in
> mlme.c
> 
> Sorry John, one of us had to deal with this :-)

No, this seems fine to me.  I'll try to stay aware of it for possible
merge conflicts...

John
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
