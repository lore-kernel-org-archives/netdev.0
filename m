From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-01-12
Date: Thu, 12 Jan 2012 12:10:23 -0800 (PST)
Message-ID: <20120112.121023.570915351051554327.davem@davemloft.net>
References: <20120112184919.GK11093@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120112184919.GK11093-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 12 Jan 2012 13:49:19 -0500

> Here is a quick batch of wireless fixes intended for 3.3!
> 
> On the Bluetooth patches, Gustavo says this:
> 
> "A couple of fixes for the 3.3 release. The majority of the fixes are
> related to the change from tasklets to workqueue in the Bluetooth
> Core. The rest are important fixes over the tree. Exception is
> 'Bluetooth: Rename extfeatures', as the name says it is just a rename
> and no harm, but it is a preparation for a following fix."
> 
> Also included is a fix from Jesper Juhl for a potential memory leak in
> brcm80211, a one-line comment fix (plus a couple of lines of removing
> unused code) from Mohammed Shafi Shajakhan in ath9k, a fix from Larry
> Finger to prevent hitting a BUG in rtl8192se when an skb allocation
> fails, a fix from Stanislaw Gruszka for a NULL pointer dereference
> in mac80211, a fix from Rajkumar Manoharan for an ath9k regression
> relating to channel noisefloor readings, and a fix from Johannes Berg
> for a regression related to parsing station flags.
> 
> Hopefully all of these are fine for the merge window.  Please let me
> know if there are problems!

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
