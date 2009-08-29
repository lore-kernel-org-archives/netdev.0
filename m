From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-08-28
Date: Fri, 28 Aug 2009 23:05:42 -0700 (PDT)
Message-ID: <20090828.230542.249636196.davem@davemloft.net>
References: <20090828191039.GC32694@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090828191039.GC32694-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 28 Aug 2009 15:10:39 -0400

> Dave,
> 
> One more late-breaker for 2.6.31...
> 
> This patch is rather large for this stage of the cycle, but it
> corrects a regression disussed recently on LKML, documented in bug
> 14016 at bugzilla.kernel.org.  This jist of it is that the ipw2200
> firmware loading routine was using an order 6 memory allocation that was
> failing with newer allocators under some circumstances.

Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
