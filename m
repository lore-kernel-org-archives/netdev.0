From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2010-02-22
Date: Thu, 25 Feb 2010 23:27:48 -0800 (PST)
Message-ID: <20100225.232748.200313445.davem@davemloft.net>
References: <20100222185638.GC2988@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100222185638.GC2988-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 22 Feb 2010 13:56:38 -0500

> Here is one more big batch of wireless bits intended for 2.6.34.  Along
> with the usual variety of driver fixes are some mac80211 bits from
> Johannes, a number of iwlwifi updates from Intel, and a big batch of of
> wl1271 bits from Nokia.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.

There were two conflicts I had to resolve (some declarations in in
iwl-core.h and one of the rt* driver PCI ID tables).

Please double-check my work when I push this out to net-next-2.6

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
