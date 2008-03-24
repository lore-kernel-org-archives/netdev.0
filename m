From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] Adding blacklist support to the pegasus driver
Date: Mon, 24 Mar 2008 17:47:14 +0100
Message-ID: <200803241747.15061.oliver@neukum.org>
References: <47E7D266.8050500@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47E7D266.8050500-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag 24 M=C3=A4rz 2008 schrieb Stefan Bader:
> I have been working on a problem which arose from the fact that (at
> least one vendor) some vendors use the same vendor and model number f=
or
> different pieces of hardware.

That issue can be solved with using the correct macros for probing that
include a device class check.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
