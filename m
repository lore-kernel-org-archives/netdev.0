From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] stmmac: Add an optional register interface clock
Date: Wed, 08 Apr 2015 14:58:38 -0400 (EDT)
Message-ID: <20150408.145838.1115385506972524636.davem@davemloft.net>
References: <1428439125-26023-1-git-send-email-abrestic@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	james.hartley-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
To: abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428439125-26023-1-git-send-email-abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Bresticker <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Date: Tue,  7 Apr 2015 13:38:45 -0700

> The DWMAC block on certain SoCs (such as IMG Pistachio) have a second
> clock which must be enabled in order to access the peripheral's
> register interface, so add support for requesting and enabling an
> optional "pclk".
> 
> Signed-off-by: Andrew Bresticker <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

Looks good, applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
