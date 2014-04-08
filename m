From: "Enrico Mioso (@atlantide)" <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Fault ammission :)
Date: Tue, 8 Apr 2014 06:55:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1404080654530.354@gmail.com>
References: <alpine.LNX.2.03.1404071046430.2161@gmail.com> <20140408002209.GB25024@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Enrico Mioso (@atlantide)" <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140408002209.GB25024-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Mon, 7 Apr 2014, Greg KH wrote:

==Date: Mon, 7 Apr 2014 17:22:09 -0700
==From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
==To: "Enrico Mioso (@atlantide)" <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
==    Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
==Subject: Re: Fault ammission :)
==
==On Mon, Apr 07, 2014 at 10:55:36AM +0200, Enrico Mioso (@atlantide) wrote:
==> Just to say - that my first COMMIT (adding support fo ONDA MT828UP) was
==> simply wrong. There was a firmware update, but it didn't influence the
==> thing, so I simply mistaken. But now, with the latter commit fixing the
==> thing, all works fine.
==> I will be better to keep udev running :) .
==> References:
==> - Patch: "usb: serial: option.c: remove ONDA MT825UP product ID fromdriver"
==> - (indirect references in this one)
==
==I don't understand, is there a patch we should now revert?
==
==thanks,
==
==greg k-h
==
No - things works fine as they are now. Thank you and sorry for the "noise".

Enrico

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
