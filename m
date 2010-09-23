From: Przemo Firszt <przemo-q9SP4D9nreWHXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH v4 0/2] Get and Set Feature Reports on HIDRAW (USB and
 Bluetooth)
Date: Thu, 23 Sep 2010 21:16:19 +0100
Message-ID: <1285272979.2869.14.camel@pldmachine>
References: <1281442367.12579.206.camel@localhost.localdomain>
	 <1281990059-3562-1-git-send-email-alan@signal11.us>
	 <20100923162521.GA15641@null>
	 <AANLkTinJXYbZh_MvG81iJMu84LKBOKL3s-Gbfe77Vq7q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ville Tervo <ville.tervo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	ext Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Stefan Achatz <erazor_de-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Stephane Chatty <chatty-rXV5z7KbLFk@public.gmane.org>,
	Michael Poole <mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Bastien Nocera <hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ping Cheng <pinglinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTinJXYbZh_MvG81iJMu84LKBOKL3s-Gbfe77Vq7q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dnia 2010-09-23, czw o godzinie 10:07 -0700, Ping Cheng pisze:
> On Thu, Sep 23, 2010 at 9:25 AM, Ville Tervo <ville.tervo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org> wrote:
> > Hi Alan,
> >
> > On Mon, Aug 16, 2010 at 10:20:57PM +0200, ext Alan Ott wrote:
> >> This is version 4. Built against 2.6.35+ revision 320b2b8de12698 .
> >
> > I gave a try to to this patch using your test tool [1] and very old BT
> > keyboard. I don't have anything else ATM to test with. Is there some BT hid
> > devices which support setting and getting features?
> 
> As far as I know Wacom BT devices (Graphire and Intuos4) need to get
> and set features.
> 
> Przemo,
> 
> Do you have time to test the patchset with your Graphire BT and
> provide your result here?
Hi Ping,
Speed switching works as expected.

Tested on HP NC4200 with internal and external bluetooth modules:

Linux pldmachine 2.6.35-07788-g320b2b8-dirty #15 Thu Sep 23 19:55:03 IST
2010 i686 Intel(R)_Pentium(R)_M_processor_1.86GHz PLD Linux

ID 03f0:011d Hewlett-Packard Integrated Bluetooth Module
ID 0a12:0001 Cambridge Silicon Radio, Ltd Bluetooth Dongle (HCI mode)

and Wacom Pen Tablet CTE-630BT

Tested-by: Przemo Firszt <przemo-q9SP4D9nreWHXe+LvDLADg@public.gmane.org>
-- 
Regards,
Przemo Firszt <przemo-q9SP4D9nreWHXe+LvDLADg@public.gmane.org>
