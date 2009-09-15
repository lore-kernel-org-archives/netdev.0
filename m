From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 2/2] ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB
 interface
Date: Tue, 15 Sep 2009 14:05:08 +0200
Message-ID: <4AAF82F4.6040708@grandegger.com>
References: <20090914080945.5441.45509.stgit@localhost.localdomain>	<20090914082229.5441.16650.stgit@localhost.localdomain>	<4AAF7301.60608@grandegger.com> <4AAF7D47.1070005@ems-wuensche.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
To: Sebastian Haas <haas-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AAF7D47.1070005-zsNKPWJ8Pib6hrUXjxyGrA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sebastian Haas wrote:
> Wolfgang Grandegger schrieb:

>> It would also be nice, if some USB guru's could have a look as well.
> Oliver Neukum already did a quick review. I've fixed serveral
> GFP_ATOMIC/KERNEL issues and a problem with DMA coherency on his feedback.

Good, just found the thread pointing out various serious issues.

Wolfgang.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
