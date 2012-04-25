From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-04-25
Date: Wed, 25 Apr 2012 15:14:13 -0400 (EDT)
Message-ID: <20120425.151413.147876040219098157.davem@davemloft.net>
References: <20120425180639.GA16900@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120425180639.GA16900-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 25 Apr 2012 14:06:39 -0400

> This is a batch of fixes intended for 3.4.
> 
> The brcmsmac patch from Eldad Zack eliminates some log spam.
> The mac80211 patch from Eliad Peller fixes a WARNING when removing
> an interface.  The two patches from Gabor Juhos combine to address
> a regression with some bad tx power settings for an Atheros chip.
> Johannes Berg gives us a fix for some bad hardware initializtion in
> iwlwifi, which resulted in hardware lockups.  Larry Finger gives us
> a fix for an oops when unloading the rtlwifi modules.  Meenakshi
> Venkataraman fixes some firmware version values in iwlwifi that
> result in attempts to load firmware that does not exist in the wild.
> Stanislav Yakovlev fixes a race condition in the ipw2200 driver.
> Finally,  Stanislaw Gruszka provides an iwlwifi fix to avoid a NULL
> pointer access.

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
