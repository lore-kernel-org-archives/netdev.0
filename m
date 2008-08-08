From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: [00/04] HSO driver bugfixes and updates
Date: Fri, 8 Aug 2008 12:00:23 -0700
Message-ID: <20080808190023.GA2953@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jari Tenhunen <jari.tenhunen-X3B1VOXEql0@public.gmane.org>,
	Olivier Blin <blino-4qZELD6FgxhWk0Htik3J/w@public.gmane.org>,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Paul Rolland <rol-fjEKYshTNZ1eoWH0uzbU5w@public.gmane.org>,
	Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff,

Here are 4 patches against 2.6.27-rc2 for the drivers/net/usb/hso.c
driver.

The first 2 fix problems that people have been having with the driver
The last 2 are just good things to have based on code reviews from Arjan
and Andrew.

Please apply them to your tree(s) and push them upward.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
