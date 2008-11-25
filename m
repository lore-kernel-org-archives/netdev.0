From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-11-25
Date: Tue, 25 Nov 2008 15:01:01 -0800 (PST)
Message-ID: <20081125.150101.153225254.davem@davemloft.net>
References: <20081125220824.GB25962@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081125220824.GB25962-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 25 Nov 2008 17:08:24 -0500

> These fixes are intended for 2.6.28.  Included are a build fix,
> a security issue (debugfs permissions), a fixup to a previous patch
> from Johannes to correct some DMA API usage, a fix to prevent mac80211
> from allowing the use of IBSS mode on channels that don't allow it,
> an ath5k fix to limit wakeups when not associate, and some ath9k DMA
> fixes for a problem that led to disk corruption...
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
