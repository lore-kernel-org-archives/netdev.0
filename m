From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC PATCH v1 1/3] usbnet: introduce usbnet_link_change API
Date: Thu, 20 Sep 2012 17:02:43 -0400 (EDT)
Message-ID: <20120920.170243.324334943379723177.davem@davemloft.net>
References: <1347978201-6219-1-git-send-email-ming.lei@canonical.com>
	<1347978201-6219-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org, finik-l0cyMroinI0@public.gmane.org,
	rjw-KKrjLPT3xs0@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347978201-6219-2-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Tue, 18 Sep 2012 22:23:19 +0800

> +void usbnet_link_change(struct usbnet *dev, int link, int need_reset)

Please use 'bool' for link and need_reset.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
