From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3/3] usbnet: fix skb traversing races during unlink(v1)
Date: Mon, 14 May 2012 18:34:13 -0400 (EDT)
Message-ID: <20120514.183413.1917543957565059489.davem@davemloft.net>
References: <20120502.201212.909292764269133334.davem@davemloft.net>
	<20120503090450.41704527@tom-ThinkPad-T410>
	<CACVXFVNYFSSP2+MFXAqT60E0qOp8+hjU3u0SbYoWHA_a5ouaxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNYFSSP2+MFXAqT60E0qOp8+hjU3u0SbYoWHA_a5ouaxw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 10 May 2012 07:47:47 +0800

> Considered that this one(v2) doesn't depend on usb tree any more and looks
> no one objects it, could you apply this one on your tree?

I will, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
