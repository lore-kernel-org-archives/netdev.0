From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4 0/6] Support the rk3399 gmac and pd function
Date: Fri, 02 Sep 2016 17:09:12 -0700 (PDT)
Message-ID: <20160902.170912.186642163235206909.davem@davemloft.net>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, frank.wang-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org, david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org, zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472752204-8924-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Date: Fri,  2 Sep 2016 01:49:58 +0800

> This patch have the following changes:
> 
> 7edf13e net: stmmac: dwmac-rk: add rk3366 & rk3399 specific data
> 26e004e net: stmmac: dwmac-rk: fixes the gmac resume after PD on/off
> b216c2f net: stmmac: dwmac-rk: add pd_gmac support for rk3399
> 848bb71 arm64: dts: rockchip: add the gmac power domain on rk3399
> 508e41f arm64: dts: rockchip: add the gmac needed node for rk3399
> fb26795 arm64: dts: rockchip: enable the gmac for rk3399 evb board
> 
> Hi David,
> The patch 1,2,3 is related to the rockchip net/stammc driver,
> 
> Hi Heiko,
> The patch 4,5,6 is related to the dts changes.

Patches 1, 2, and 3 applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
