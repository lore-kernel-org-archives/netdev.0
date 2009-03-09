From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-03-06
Date: Sun, 08 Mar 2009 20:02:07 -0700 (PDT)
Message-ID: <20090308.200207.90768249.davem@davemloft.net>
References: <20090306212414.GG3712@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090306212414.GG3712-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 6 Mar 2009 16:24:14 -0500

> Here are a few small patches intended for 2.6.29.
> 
> Two of them add USB IDs to the Ralink drivers.  Some of those IDs are
> already in -next, so there will be some minor conflicts.
> 
> The one from Roel Kluin avoids checking for <0 on an unsigned variable.
> It seems like a very low-risk fix to a potentially hard to find
> problem, so it seems worthwhile to me.
> 
> The iwlwifi fix corrects some problems with cleaning-up after
> initialization errors, avoiding some potential resources leaks.
> 
> The p54 patch corrects a crash that was unveiled by applying a patch
> headed to -next.  The problem was their all along, so it seems work
> taking now.

Pulled, thanks a lot John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
