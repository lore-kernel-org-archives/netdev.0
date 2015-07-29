From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/4] dwc_eth_qos: Add support for Synopsys DWC
 Ethernet QoS
Date: Wed, 29 Jul 2015 00:10:27 -0700 (PDT)
Message-ID: <20150729.001027.425054389792319502.davem@davemloft.net>
References: <1438077710-19175-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andire-VrBV9hrLPhE@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	larper-VrBV9hrLPhE@public.gmane.org
To: lars.persson-VrBV9hrLPhE@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1438077710-19175-1-git-send-email-larper-VrBV9hrLPhE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>
Date: Tue, 28 Jul 2015 12:01:46 +0200

> This is a driver supporting version 4.10a of the Synopsys DWC Ethernet QoS
> gigabit ethernet controller. The IP has changed significantly compared to the
> dwmac1000 so a separate driver is justified.
> 
> The IP is highly configurable at synthesis time. This driver has been
> developed for a subset of the total available feature set. Currently
> it supports:
> * TSO
> * Checksum offload for RX and TX.
> * Energy efficient ethernet.
> * GMII phy interface.
> * The statistics module.
> * Single RX and TX queue.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
