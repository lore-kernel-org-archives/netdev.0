From: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] Adding blacklist support to the pegasus driver
Date: Tue, 25 Mar 2008 22:44:13 +0200 (EET)
Message-ID: <alpine.DEB.1.10.0803252242550.3288@bender.nucleusys.com>
References: <47E7D266.8050500@canonical.com> <200803241747.15061.oliver@neukum.org> <alpine.DEB.1.10.0803252204180.3163@bender.nucleusys.com> <200803252135.29249.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811350-293716320-1206477853=:3288"
Cc: Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200803252135.29249.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811350-293716320-1206477853=:3288
Content-Type: TEXT/PLAIN; charset=utf-8; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 25 Mar 2008, Oliver Neukum wrote:

> Am Dienstag, 25. M=C3=A4rz 2008 21:05:31 schrieb Petko Manolov:
>> On Mon, 24 Mar 2008, Oliver Neukum wrote:
>>
>>> Am Montag 24 M=C3=A4rz 2008 schrieb Stefan Bader:
>>>> I have been working on a problem which arose from the fact that (at
>>>> least one vendor) some vendors use the same vendor and model number fo=
r
>>>> different pieces of hardware.
>>>
>>> That issue can be solved with using the correct macros for probing that
>>> include a device class check.
>>
>> Can you show a driver that is already doing that.  I am sorry to be so
>> lazy, but i can't help it... :-)
>
> http://fixunix.com/kernel/256881-add-infamous-huawei-e220-option-c-3.html
>
> Just ask and you shall be answered.

Ah, now i see. :-)

This (if works) seems simpler and more elegant.  I'll play with it in the=
=20
morning.  Thanks for the link.


 =09=09Petko
---1463811350-293716320-1206477853=:3288--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
