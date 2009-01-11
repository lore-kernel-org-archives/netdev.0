From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: decisions, decisions...
Date: Sat, 10 Jan 2009 23:57:40 -0800 (PST)
Message-ID: <20090110.235740.20607970.davem@davemloft.net>
References: <20090110.235141.223618374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090110.235141.223618374.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Sat, 10 Jan 2009 23:51:41 -0800 (PST)

> So I'm going to rework the net-2.6 tree do that only bug fixes and
> -RCx material remains in there.  In particular the latest batch
> of net_dev_ops conversions are getting pulled out.
> 
> I'm going to put those removed changes aside somewhere locally, and I
> will not push them into net-next-2.6 until Stephen Rothwell gives the
> OK for that kind of stuff showing up in -next.

BTW, in case it wasn't obvious, this means net-2.6 will need to be
rebased.

I'll make a posting here when that has been completed.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
