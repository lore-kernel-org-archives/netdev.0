From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: only honor IW_SCAN_THIS_ESSID in STA, IBSS,
 and AP modes
Date: Wed, 17 Oct 2007 21:16:32 -0700 (PDT)
Message-ID: <20071017.211632.40832065.davem@davemloft.net>
References: <200710162329.55966.flamingice@sourmilk.net>
	<20071017145315.GC5744@tuxdriver.com>
	<11926328942540-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11926328942540-git-send-email-linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 17 Oct 2007 10:54:54 -0400

> The previous IW_SCAN_THIS_ESSID patch left a hole allowing scan
> requests on interfaces in inappropriate modes.
> 
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

John I've pulled from your tree and added this patch on top.

Thanks!
