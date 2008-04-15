From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 10:01:14 +0200 (CEST)
Message-ID: <alpine.DEB.0.99.0804150951100.6062@FWR-FLAB>
References: <20080414213238.GB28833@kroah.com> <20080414215905.GD16272@one-eyed-alien.net>
 <200804142342.08116.ajb@spheresystems.co.uk>
 <20080414230309.GA1672@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii; format=flowed
Cc: "Andrew Bird (Sphere Systems)" <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Matthew Dharm <mdharm-usb-JGfshJpz5UybPZpvUQj5UqxOck334EZe@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080414230309.GA1672-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


"
This driver is used for Option HSDPA/HSUPA cards that support
downlink speeds of 7.2Mbps or greater.
"

How does that sound ?

Regards,

Filip-

On Mon, 14 Apr 2008, Greg KH wrote:

> On Mon, Apr 14, 2008 at 11:42:07PM +0100, Andrew Bird (Sphere Systems) wrote:
>> Hi Matthew,
>> 	I'd prefer the keep it as just 'hso' and change the textual description if
>> necessary. I think module names are just arbitrary, and should not
>> necessarily reflect the original usage too well, otherwise you end up with a
>> situation like with the 'option' module. That module is now used for many
>> devices from differing manufacturers and it doesn't really make much sense to
>> load the option module to service a device from Novatel, Sierra Wireless or
>> Huawei.
>
> Ok, that's fine with me, what should we use for the text in the driver
> and the Kconfig entry?
>
> thanks,
>
> greg k-h
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
