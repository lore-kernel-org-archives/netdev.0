From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-03-30
Date: Sun, 01 Apr 2012 16:10:31 -0400 (EDT)
Message-ID: <20120401.161031.886756026206260043.davem@davemloft.net>
References: <20120330175533.GC8273@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120330175533.GC8273-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 30 Mar 2012 13:55:34 -0400

> I have a few more small fixes, hopefully still in time for 3.4-rc1...
> 
> Rajkukmar provides us with a one-line timestamp correction related to
> scanning in mac80211.  Sujith gives us a small fixup for a regression
> in the handling of HT capability bits for ath9k.  Stanislav Yakovlev
> is stepping-up as maintainer for the ipw2x00 drivers, so we'll add
> him to MAINTAINERS.  Stanislav also gives us a fix for a thinko
> that registers the wrong band information for ipw2200 and 802.11a.
> Finally, Santosh Nayak adds some simple error checking to orinoco to
> avoid some potential NULL pointer dereferences.

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
