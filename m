From: Greg KH <gregKH-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 0 / 5] move the common CDC parser
Date: Sat, 16 Jul 2016 06:57:21 +0900
Message-ID: <20160715215721.GA6897@kroah.com>
References: <1468503694-9482-1-git-send-email-oneukum@suse.com>
 <20160715.115147.1896139966807241395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oneukum-IBi9RG/b67k@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160715.115147.1896139966807241395.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 15, 2016 at 11:51:47AM -0700, David Miller wrote:
> From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
> Date: Thu, 14 Jul 2016 15:41:29 +0200
> 
> > Experience has shown that making all CDC drivers depend on usbnet
> > is not practical, because some of them are not network drivers.
> > So this patch moves the common parser from usbnet into the messages
> > helpers of usbcore.
> > The rest of the series applies it to the non-network CDC drivers.
> > 
> > I hope it can go through Greg's tree although it touches usbnet.
> 
> I'm fine with Greg taking this series, sure.

Ok, I'll take it, thanks.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
