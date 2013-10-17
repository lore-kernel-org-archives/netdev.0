From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2013-10-15
Date: Thu, 17 Oct 2013 16:06:20 -0400 (EDT)
Message-ID: <20131017.160620.433147354971362075.davem@davemloft.net>
References: <20131015175611.GA15706@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131015175611.GA15706-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 15 Oct 2013 13:56:12 -0400

> Please pull this batch of fixes intended for the 3.12 stream!
> 
> For the mac80211 bits, Johannes says:
> 
> "Jouni fixes a remain-on-channel vs. scan bug, and Felix fixes client TX
> probing on VLANs."
> 
> And also:
> 
> "This time I have two fixes from Emmanuel for RF-kill issues, and fixed
> two issues reported by Evan Huus and Thomas Lindroth respectively."
> 
> On top of those...
> 
> Avinash Patil adds a couple of mwifiex fixes to properly inform cfg80211
> about some different types of disconnects, avoiding WARNINGs.
> 
> Mark Cave-Ayland corrects a pointer arithmetic problem in rtlwifi,
> avoiding incorrect automatic gain calculations.
> 
> Solomon Peachy sends a cw1200 fix for locking around calls to
> cw1200_irq_handler, addressing "lost interrupt" problems.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
