From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-06-10
Date: Wed, 10 Jun 2009 23:44:24 -0700 (PDT)
Message-ID: <20090610.234424.69074010.davem@davemloft.net>
References: <20090610185639.GC3892@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090610185639.GC3892-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 10 Jun 2009 14:56:39 -0400

> Despite my previous optimistic prediction, I need to ask for one more
> 2.6.31 pull before/during the merge window... :-)
> 
> This one actually does have a number of bug fixes embedded within, as
> well as some further fleshing-out and usage of the new rfkill
> infrastructure changes that are already queued for 2.6.31.  The other
> bits are more minor, but they have already spent at least a few days in
> -next and I believe they are safe for 2.6.31.

Pulled, I'll push out after some build verifications.

> P.S.  For some reason (probably the 2.6.30 release) the public push on
> kernel.org seems to be taking a lot longer than usual.  So you probably
> want to ensure that the wireless-next-2.6 head matches 2f0accc13520 or
> just pull using ssh (or direct file access).

I verified this, but you can sidestep this entire problem by simply
giving me master.kernel.org SSH based URLs to pull from. :-)

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
