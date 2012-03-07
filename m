From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-03-06
Date: Wed, 07 Mar 2012 15:39:13 -0500 (EST)
Message-ID: <20120307.153913.824845751182717386.davem@davemloft.net>
References: <20120306201528.GC3353@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120306201528.GC3353-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 6 Mar 2012 15:15:28 -0500

> Here are a few more squeakers hoping for 3.3...
> 
> Two of them are for carl9170: a one-line fix for a memory accounting
> leak; and a fix that corrects the handling of frames with a couple of
> status flags set by mac80211 (enabling delivery to sleeping stations).
> Also included is a one-liner for mwifiex that should have been included
> in "mwifiex: clear previous security setting during association".
> Finally, a one-line fix from Johannes Berg for an iwlwifi regression
> brings-up the rear.
> 
> Please let me know if there are problems!

Pulled, but no promises getting these into 3.3
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
