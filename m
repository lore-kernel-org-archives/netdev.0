From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Transfer of maintainership
Date: Wed, 4 May 2011 07:45:11 +0200
Message-ID: <20110504054511.GA3362@riccoc20.at.omicron.at>
References: <201104291419.04498.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201104291419.04498.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2011 at 02:19:04PM +0200, Oliver Neukum wrote:

>  USB "USBNET" DRIVER FRAMEWORK
> -M:	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> +M:	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

Oliver,

We have been looking at usbnet and a have question.

Usbnet doesn't use either phylib or napi, but I think the reason is
probably purely historical. Is there a technical reason why phylib or
napi won't work with usbnet devices?

If not, I would like to convert them in the near future.

Thanks,

Richard
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
