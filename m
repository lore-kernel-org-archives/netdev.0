From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3/3] usbnet: fix skb traversing races during unlink(v1)
Date: Wed, 02 May 2012 20:12:12 -0400 (EDT)
Message-ID: <20120502.201212.909292764269133334.davem@davemloft.net>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
	<1335775864-4873-4-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335775864-4873-4-git-send-email-tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 30 Apr 2012 16:51:04 +0800

> This patch depends on the usb_block_urb/usb_unblock_urb patch from
> Oliver.

Therefore I cannot apply it to any of my trees.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
