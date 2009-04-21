From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/2] usb driver for intellon int51x1 based PLC like
 devolo dlan duo
Date: Tue, 21 Apr 2009 01:57:08 -0700 (PDT)
Message-ID: <20090421.015708.65867910.davem@davemloft.net>
References: <0681089db5bdc5acc805ed52130dc9a5.squirrel@webmail.it-technology.at>
	<Pine.LNX.4.64.0904181834210.3691@wrl-59.cs.helsinki.fi>
	<5c52681c17a9cd66ec59e9d9cad3ee46.squirrel@webmail.it-technology.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: peter-xHLhtm3VSFg@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5c52681c17a9cd66ec59e9d9cad3ee46.squirrel-2RFepEojUI1IVnL2akGZhTp0pij5GnPV@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Peter Holik" <peter-xHLhtm3VSFg@public.gmane.org>
Date: Sat, 18 Apr 2009 18:42:59 +0200 (CEST)

> I am submitting a series of 2 patches for inclusion in 2.6.30.
> Here is a brief description of the patch series:
> - because of using the same function get_ethernet_addr as cdc_ether.c
>   i export usbnet_get_ethernet_addr from usbnet and fixed cdc_ether
>   (suggested by Oliver Neukum).
> - usb driver for intellon int51x1 based PLC like devolo dlan duo
>   with improvements suggested by the guys of the mailinglist

I've applied the most recent version of this driver submission
to net-next-2.6, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
