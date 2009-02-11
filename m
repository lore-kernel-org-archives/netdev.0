From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-02-11
Date: Wed, 11 Feb 2009 13:58:01 -0800 (PST)
Message-ID: <20090211.135801.242440425.davem@davemloft.net>
References: <20090211191212.GA7033@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090211191212.GA7033-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 11 Feb 2009 14:12:12 -0500

> Here are a few more intended for 2.6.29.  The ath5k one is already in
> -next, but it turns-out to affect 2.6.29 as well.  The two zd1211rw ones
> are one-liners that enable new hardware for that driver.
> 
> The iwlwifi patch corrects a problem (introduced by the previous iwlwifi
> fix) that disables the iwlwifi devices after suspend/resume.  It will
> conflict with what is already in -next -- just take the hunks that are
> already in -next and ignore the hunks introduced here.
> 
> Please let me know if there are problems!

Pulled, thanks a lot John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
