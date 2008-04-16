From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Wed, 16 Apr 2008 15:53:14 +0200
Message-ID: <200804161553.14879.oliver@neukum.org>
References: <200804161428.18066.oliver@neukum.org> <4805F9DB.5030004@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4805F9DB.5030004-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 16. April 2008 15:06:35 schrieb Paulius Zaleckas:
> Oliver Neukum wrote:
> > Hi,
> > 
> > could you test this patch?
> > It does away with the one off serial ioctl replacing it with a standard
> > mechanism.
> > 
> 
> Can you describe me how can I test it? I am pretty new to rfkill :)

So am I.

> By looking at rfkill documentation I got impression that it will work
> only on laptop... and I am using desktop PC.

Indeed. it seems like you need a key. Can you enquire on the kernel list?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
