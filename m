From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V3] net: mediatek: update the IRQ part of the binding
 document
Date: Thu, 14 Apr 2016 16:45:30 -0400 (EDT)
Message-ID: <20160414.164530.1080495164848466603.davem@davemloft.net>
References: <1460442918-6070-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1460442918-6070-1-git-send-email-blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Date: Tue, 12 Apr 2016 08:35:18 +0200

> The current binding document only describes a single interrupt. Update the
> document by adding the 2 other interrupts.
> 
> The driver currently only uses a single interrupt. The HW is however able
> to using IRQ grouping to split TX and RX onto separate GIC irqs.
> 
> Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
