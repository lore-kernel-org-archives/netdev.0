From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Mon, 20 Jun 2011 08:47:51 +0200
Message-ID: <201106200847.51725.oneukum@suse.de>
References: <20110611200625.GB14582@kroah.com> <201106141146.19097.oneukum@suse.de> <4DFE6FD8.1080003@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DFE6FD8.1080003-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 19. Juni 2011, 23:53:28 schrieb Marius Kotsbak:
> On 14. juni 2011 11:46, Oliver Neukum wrote:
> > Am Dienstag, 14. Juni 2011, 11:32:00 schrieb Marius Kotsbak:
> >> Den 14. juni 2011 10:49, skrev Oliver Neukum:

> > The API is correct. You just need to copy the init strings into buffers
> > allocated with kmalloc.
> >
> 
> This should be addressed in the extra patch just sent. And it still
> works on my x86-64.

x86-64 works. ppc and arm are hurt.

> The 2 patches might be squashed if desired.

 David?

> Okay, I can see the reasoning behind that. The problem is just that it
> would be nice to avoid it because >1.1.4 versions of it does not work
> with this modem, but that can be addressed there as well.

All's well, as far as I can see.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
