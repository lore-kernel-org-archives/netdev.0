From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-10-29
Date: Fri, 30 Oct 2015 20:39:06 +0900 (KST)
Message-ID: <20151030.203906.57461318217584400.davem@davemloft.net>
References: <87d1vxo3ap.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87d1vxo3ap.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Thu, 29 Oct 2015 21:58:06 +0200

> here's hopefully my last pull request for 4.4. ssb had a new Kconfig
> entry and that's why this touches arch/mips/bcm47xx/Kconfig. ssb also
> did some code shuffling and moved code from b43 to ssb subsystem.
> Otherwise should be business as usual.
> 
> While writing this I noticed that Fengwei Yin had a problem with the
> From field and that's why you see "yfw" in the stats below. I considered
> that this isn't a big enough problem to justify rebasing my tree, but
> let me know if you think otherwise.
> 
> Please let me know if there are any problems.

Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
