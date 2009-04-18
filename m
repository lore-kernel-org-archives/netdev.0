From: "Peter Holik" <peter-xHLhtm3VSFg@public.gmane.org>
Subject: [PATCH 0/2] new usb driver int51x1 overview
Date: Sat, 18 Apr 2009 19:24:11 +0200 (CEST)
Message-ID: <bbff2b8e6400b0db79d3244ea02fba82.squirrel@webmail.it-technology.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Netdev" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "LKML" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I am submitting a series of 2 patches for inclusion in 2.6.30.
Here is a brief description of the patch series:
- because of using the same function get_ethernet_addr as cdc_ether.c
  i export usbnet_get_ethernet_addr from usbnet and fixed cdc_ether (suggested by Oliver Neukum).
- usb driver for intellon int51x1 based PLC like devolo dlan duo
  with improvements suggested by the guys of the mailinglist

cu Peter



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
