From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wirelss 2011-12-09
Date: Sun, 11 Dec 2011 15:02:40 -0500 (EST)
Message-ID: <20111211.150240.2083787980841719527.davem@davemloft.net>
References: <20111209192228.GC14236@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111209192228.GC14236-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 9 Dec 2011 14:22:28 -0500

> This is a collection of fixes intended for 3.2.
> 
> Gustavo describes the Blueooth bits thusly: "Some fixes for 3.2:
> support for a new Marvell device, two module reference fixes, a memory
> leak fix and finally a check in a HCI version check."
> 
> Additionally, we have an ath9k fix for a regression on single-stream
> chips, a mac80211 fix for a race in aggregation start (looks big due
> to moving some functions to avoid forward declarations), a fix for
> some improper power state management in the rtlwifi suite, and a fix
> for an ssb init regression on some SoCs.
> 
> Please let me know if there are problems!

Pulled, thanks John.

As we wind down towards the end of these RCs, please exert even
more pushback on bug fixes from now until 3.2 goes out.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
