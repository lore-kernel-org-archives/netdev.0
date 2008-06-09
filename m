From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-06-09
Date: Mon, 09 Jun 2008 15:39:14 -0700 (PDT)
Message-ID: <20080609.153914.154669065.davem@davemloft.net>
References: <20080609210858.GB15375@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080609210858.GB15375-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Mon, 9 Jun 2008 17:08:58 -0400

> Dave,
> 
> Here is another round of fixes intended for 2.6.26.  Most of them are
> small and obvious.
> 
> The ipw2200 one [1] is big, but a lot of it is moving and/or deleting some
> old code.  It fixes a problem that can cause a new scan request to
> eclipse and existing one in a way that keeps userland from getting the
> requested scan results.
> 
> Please let me know if there are problems!

Pulled and pushed back out to net-2.6, thanks John!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
