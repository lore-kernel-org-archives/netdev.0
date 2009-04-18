From: "Peter Holik" <peter-xHLhtm3VSFg@public.gmane.org>
Subject: [PATCH 0/2] usb driver for intellon int51x1 based PLC like devolo
     dlan duo
Date: Sat, 18 Apr 2009 18:42:59 +0200 (CEST)
Message-ID: <5c52681c17a9cd66ec59e9d9cad3ee46.squirrel@webmail.it-technology.at>
References: <cb6d2886e87af66d945f1052e6eb8a85.squirrel@webmail.it-technology.at>
    <Pine.LNX.4.64.0904181311470.3600@wrl-59.cs.helsinki.fi>
    <0681089db5bdc5acc805ed52130dc9a5.squirrel@webmail.it-technology.at>
    <Pine.LNX.4.64.0904181834210.3691@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Netdev" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "LKML" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0904181834210.3691-x/A8LOkYjdVsRR2hCrRKtT03IgOmwywn@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I am submitting a series of 2 patches for inclusion in 2.6.30.
Here is a brief description of the patch series:
- because of using the same function get_ethernet_addr as cdc_ether.c
  i export usbnet_get_ethernet_addr from usbnet and fixed cdc_ether
  (suggested by Oliver Neukum).
- usb driver for intellon int51x1 based PLC like devolo dlan duo
  with improvements suggested by the guys of the mailinglist

cu Peter

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
