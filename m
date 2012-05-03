From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-05-03
Date: Thu, 03 May 2012 13:05:16 -0400 (EDT)
Message-ID: <20120503.130516.1008806127286088740.davem@davemloft.net>
References: <20120503152206.GL9285@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120503152206.GL9285-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 3 May 2012 11:22:06 -0400

> This is a batch of updates intended for 3.5.  It also includes a pull
> from the wireless tree which resolved some build dependencies.
> 
> Highlights of this pull request include some refactoring in the
> bluetooth directories, some HT enhancements for mac80211, an expansion
> of the ethtool support for cfg80211- and mac80211-based drivers,
> and some more iwlwifi refactoring.
> 
> It looks like some of the bluetooth device ID patches got committed
> on both the bluetooth and the bluetooth-next trees.  I'll ask them to
> be more careful about that, but I didn't think it was worth asking
> for rebases since that would be disruptive to the downstream trees
> and since git handles the situation reasonably well already.

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
