From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-11-17
Date: Thu, 17 Nov 2011 14:34:45 -0500 (EST)
Message-ID: <20111117.143445.52753444311198143.davem@davemloft.net>
References: <20111117182939.GD32622@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111117182939.GD32622-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 17 Nov 2011 13:29:39 -0500

> Here is a huge pull request for wireless bits intended for 3.3.  I
> reckon that the extended release cycle for 3.1 led to a backlog of new
> work that appeared during the merge window for 3.2?
> 
> At any rate...there is a big Bluetooth pull with a lot of code
> refactoring; a lot of brcm80211 bits including cleanups, refactoring,
> and some new hardware support; the normal set of iwlwifi updates plus
> some refactoring; an unusual large flurry of mac80211 and cfg80211
> updates from Johannes (including the new wireless TX status socket
> option); some updates to the new NFC subsystem; and the usual collection
> of other driver and mac80211 updates.  This also includes a pull of the
> wireless.git tree to resolve some build issues.

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
