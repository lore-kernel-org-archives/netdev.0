From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] usbnet: fix error return code in usbnet_probe()
Date: Thu, 17 Oct 2013 15:40:11 -0400 (EDT)
Message-ID: <20131017.154011.482777982551209327.davem@davemloft.net>
References: <CAPgLHd9jQfT2Kzi5o+3KPy0hFrkHL135K2aYp7OXcbLX4Cmkcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum-l3A5Bk7waGM@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPgLHd9jQfT2Kzi5o+3KPy0hFrkHL135K2aYp7OXcbLX4Cmkcg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sat, 12 Oct 2013 14:24:08 +0800

> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> 
> Fix to return -ENOMEM in the padding pkt alloc fail error handling
> case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Applied, thanks Wei.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
