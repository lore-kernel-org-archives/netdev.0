From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-05-20
Date: Tue, 20 May 2008 20:41:57 -0700 (PDT)
Message-ID: <20080520.204157.93481519.davem@davemloft.net>
References: <20080521025716.GA11085@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080521025716.GA11085-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 20 May 2008 22:57:16 -0400

> Another round of fixes intended for 2.6.26...one of these ("ath5k: Fix
> loop variable initializations") is already queued in net-next-2.6, but
> it fixes the following bugzilla:
> 
> 	http://bugzilla.kernel.org/show_bug.cgi?id=10605
> 
> Also included is "mac80211: fix NULL pointer dereference in
> ieee80211_compatible_rates", which fixes another bugzilla:
> 
> 	http://bugzilla.kernel.org/show_bug.cgi?id=10755

Pulled and pushed back out to net-2.6, thanks John!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
