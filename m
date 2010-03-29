From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: re-submit [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Mon, 29 Mar 2010 11:50:02 -0700
Message-ID: <20100329185002.GA13214@kroah.com>
References: <1269888076.29770.6.camel@Linuxdev3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1269888076.29770.6.camel@Linuxdev3>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 29, 2010 at 11:41:16AM -0700, Elina Pasheva wrote:
> This patch has been tested on the latest stable kernel-2.6.33.1.

It should be tested on 2.6.34-rc2, as that is the development tree.

> ---
> 
>  drivers/net/usb/Kconfig |   10 ++++++++++
>  1 file changed, 10 insertions(+)

Um, what did you use to generate this diff?  You modified more than just
one file, all of them should show up in the diffstat.

wierd,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
