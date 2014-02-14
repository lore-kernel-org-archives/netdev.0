From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v5 00/10] Support for the Broadcom GENET driver
Date: Fri, 14 Feb 2014 00:29:01 -0500 (EST)
Message-ID: <20140214.002901.293996041341946875.davem@davemloft.net>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392336531-28875-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 13 Feb 2014 16:08:41 -0800

> This patchset adds support for the Broadcom GENET Gigabit Ethernet MAC
> controller. This controller is found on the Broadcom BCM7xxx Set Top Box
> System-on-a-chips.
> 
> Changes since v4:
> - add dependency on CONFIG_OF
> 
> Changes since v3:
> - fixed Kconfig dependency on FIXED_PHY
> 
> Changes since v2:
> - dropped the patch that adds an "internal" phy-mode

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
