From: Pavel Machek <pavel-ynQEQJNshbs@public.gmane.org>
Subject: Re: AP firmware for TI wl1251 wifi chip (wl1251-fw-ap.bin)
Date: Sun, 10 Apr 2016 13:51:41 +0200
Message-ID: <20160410115141.GD30188@xo-6d-61-c0.localdomain>
References: <201603200040.26045@pali>
 <20160404123944.GA8413@pali>
 <AE1C82FB3D0EC64DB1F752C81CBD1101390F6305@DFRE01.ent.ti.com>
 <201604061412.43684@pali>
 <AE1C82FB3D0EC64DB1F752C81CBD1101390F685E@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>, "Balbi, Felipe" <balbi-l0cyMroinI0@public.gmane.org>,
	"Chalmers, Kevin" <kev-l0cyMroinI0@public.gmane.org>, Shahar Levi <shahar_levi-l0cyMroinI0@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"Davis, Andrew" <afd-l0cyMroinI0@public.gmane.org>, "Mishol, Guy" <guym-l0cyMroinI0@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, Gery Kahn <geryk-l0cyMroinI0@public.gmane.org>,
	Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	David Gnedt <david.gnedt-KfBRzk3UKwrZI3uBz1zZ2F6hYfS7NtTn@public.gmane.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	"Menon, Nishanth" <nm-l0cyMroinI0@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel@vger.k
To: "Machani, Yaniv" <yanivma-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE1C82FB3D0EC64DB1F752C81CBD1101390F685E-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi!

> > > wl1251 does not support AP mode, so there is no firmware for it in 
> > > the tree.
> > >
> > > Regards,
> > > Yaniv
> > 
> > Hi Yaniv! I read on some TI whitepaper, that wl1251 hardware supports 
> > some Soft-AP mode. So I expect that either special FW is needed for it 
> > or somehow it is possible to use current released. Do you have any information about it?
> 
> Hi Pali,
> This must be some typo, the device does not support Soft-AP.
> More than that, wl1251 family is not officially supported via the mainline Linux.


> For Soft-AP, and other new features based on Linux you should use WiLink8 chip family.

Too late for that, we already have the devices, and they were manufactured quite long
time ago.

Is it "hardware can't do AP", "firmware can't do AP" or "current drivers 
do not support AP"?

Best regards,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
