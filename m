From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] hostap: remove netif_stop_queue from init
Date: Fri, 17 Dec 2010 13:32:44 -0800 (PST)
Message-ID: <20101217.133244.48510021.davem@davemloft.net>
References: <alpine.SOC.1.00.1012100918300.15996@math.ut.ee>
	<20101210.094747.193727608.davem@davemloft.net>
	<alpine.SOC.1.00.1012172324340.24976@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j@w1.fi, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: mroos-Y27EyoLml9s@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.SOC.1.00.1012172324340.24976-ptEonEWSGqKptlylMvRsHA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date: Fri, 17 Dec 2010 23:27:50 +0200 (EET)

> Fix runtime warning with backtrace from hostap by removing 
> netif_stop_queue() call before register_netdev. Tested to work fine on 
> hostap_pci Prism 2.5.
> 
> Signed-off-by: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

John, please apply this.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
