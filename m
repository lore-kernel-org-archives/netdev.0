From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-09-22
Date: Sat, 22 Sep 2012 15:51:33 -0400 (EDT)
Message-ID: <20120922.155133.484429173339077143.davem@davemloft.net>
References: <20120922171341.GB2101@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120922171341.GB2101-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Sat, 22 Sep 2012 13:13:42 -0400

> Please pull this last(?) batch of fixes intended for 3.6...
> 
> For the Bluetooth bits, Gustavo says this:
> 
> "Here goes probably my last update to 3.6. It includes the two patches
> you were ok last week(from Andrzej Kaczmarek), those are critical
> ones, and two other fixes one for a system crash and the other for
> a missing lockdep annotation."
> 
> The referenced fixes from Andrzej prevent attempts to configure devices
> that are powered-off.
> 
> Along with the Bluetooth fixes, there are a couple of 802.11 fixes.
> Emmanuel Grumbach gives us an iwlwifi fix to prevent releasing an
> interrupt twice.  Luis R. Rodriguez provides a fix for a possible
> circular lock dependency in the cfg80211 regulatory enforcement code.
> 
> All of these have been in linux-next for a few days.  I hope they are
> not too late to make the 3.6 release!

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
