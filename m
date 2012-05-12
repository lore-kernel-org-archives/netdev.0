From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 00/17 v5] usb/net: rndis: first step toward
 consolidation
Date: Sat, 12 May 2012 15:22:17 -0400 (EDT)
Message-ID: <20120512.152217.1750282905566934209.davem@davemloft.net>
References: <1336810518-2514-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, jussi.kivilinna-E01nCVcF24I@public.gmane.org,
	haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
To: linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1336810518-2514-1-git-send-email-linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Date: Sat, 12 May 2012 10:15:18 +0200

> A fifth iteration of the first steps of RNDIS consolidation.
> 
> This version mainly address byte order issues found with
> sparse by Jussi Kivilinna, his fixes are folded into patch 1.
> At the end I have added Jussis patches cleaning up rndis_host and
> rndis_wlan based on top of this series.

ALl applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
