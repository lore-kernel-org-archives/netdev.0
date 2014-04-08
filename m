From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: Fault ammission :)
Date: Mon, 7 Apr 2014 17:22:09 -0700
Message-ID: <20140408002209.GB25024@kroah.com>
References: <alpine.LNX.2.03.1404071046430.2161@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: "Enrico Mioso (@atlantide)" <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.03.1404071046430.2161-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 07, 2014 at 10:55:36AM +0200, Enrico Mioso (@atlantide) wrote:
> Just to say - that my first COMMIT (adding support fo ONDA MT828UP) was
> simply wrong. There was a firmware update, but it didn't influence the
> thing, so I simply mistaken. But now, with the latter commit fixing the
> thing, all works fine.
> I will be better to keep udev running :) .
> References:
> - Patch: "usb: serial: option.c: remove ONDA MT825UP product ID fromdriver"
> - (indirect references in this one)

I don't understand, is there a patch we should now revert?

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
