From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/4] STM32F429: Add Ethernet fixes
Date: Thu, 20 Oct 2016 14:41:40 -0400 (EDT)
Message-ID: <20161020.144140.1794871934594140769.davem@davemloft.net>
References: <1476976886-23781-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476976886-23781-1-git-send-email-alexandre.torgue-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
Date: Thu, 20 Oct 2016 17:21:22 +0200

> This series adds several fixes for Ethernet for stm32f429 MCU.
> First 2 patches have already been reviewed some months ago when 
> stm32 Ethernet glue has been pushed (I added in this series to keep
> history). Fixes are:
>  -Change DT to be compliant to stm32 ethernet glue binding
>  -Add phy-handle to correctly use mdio subnode
>  -Remove WoL support

I'm assuming this will be merged via the ARM tree.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
