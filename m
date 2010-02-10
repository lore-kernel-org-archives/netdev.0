From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH] usbnet: convert dev(dbg|err|warn|info) macros to usbnet_(dbg|err|warn|info)
Date: Tue, 9 Feb 2010 22:56:29 -0800
Message-ID: <201002092256.30175.david-b@pacbell.net>
References: <3d8577211d88cce1fb6f4c1b54c5aa413a1f325a.1265765892.git.joe@perches.com> <201002092153.22322.david-b@pacbell.net> <1265782578.20626.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Greg Kroah-Hartman" <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1265782578.20626.17.camel-AkRN8/LKpobuYGix6ZUp1Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 February 2010, Joe Perches wrote:

> netdev_printk macros instead.
> 
> http://patchwork.ozlabs.org/patch/44955/

That'd make sense.  Had they existed way back when ...
they could have been used instead of custom stuff.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
