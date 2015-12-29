From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RESEND PATCH v1 0/4] Add support emac for the RK3036 SoC
 platform
Date: Tue, 29 Dec 2015 15:53:14 -0500 (EST)
Message-ID: <20151229.155314.1522114236952280828.davem@davemloft.net>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	leozwang-hpIqsD4AKlcxg7vii5yOFA@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451287341-16453-1-git-send-email-zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


You have to submit this series properly, the same problem happend twice
now.

When you submit a series you should:

1) Make it clear which tree you expect these changes to be applied
   to.  Here it is completely ambiguous, do you want it to go into
   my networking tree or some other subsystem tree?

2) You MUST keep all parties informed about all patches for a series
   like this.  That means you cannot drop netdev from patch #4 as
   you did both times.  Doing this aggravates the situation for
   #1 even more, because if a patch is not CC:'d to netdev it does
   not enter patchwork.  And if it doesn't go into patchwork, I'm
   not looking at it.

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
