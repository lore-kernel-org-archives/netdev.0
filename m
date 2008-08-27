From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: question wrt /drivers/char/tty_io.c in pre 2.6.16 code
Date: Wed, 27 Aug 2008 09:19:43 -0700
Message-ID: <20080827161943.GF19710@kroah.com>
References: <20080820010353.593820280@mini.kroah.org> <20080820010752.GB3365@kroah.com> <48B52064.9070700@pobox.com> <48B578F3.1050908@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48B578F3.1050908-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 27, 2008 at 05:55:31PM +0200, Denis Joseph Barrow wrote:
> Hi all,
> In kernels prior to 2.6.16

Hm, why do we care about kernels that are 2 1/2 years old?  We can't do
anything to modify them at this point in time and the only ones
supporting them are the enterprise distros.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
