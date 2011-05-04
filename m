From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] usbnet: runtime pm: fix out of memory
Date: Wed, 4 May 2011 09:26:12 +0200
Message-ID: <201105040926.12355.oneukum@suse.de>
References: <1304066229-30875-1-git-send-email-tom.leiming@gmail.com> <201105030953.44131.oneukum@suse.de> <BANLkTinZK_qjO7u+ckG_83_paVyMeyrgPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTinZK_qjO7u+ckG_83_paVyMeyrgPw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 4. Mai 2011, 08:59:41 schrieb Ming Lei:
> Hi,
>=20
> 2011/5/3 Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>:
>=20
> > Do the devices in question use cdc_ether?
>=20
> No, the device is smsc95xx, which is compound device and is
> integrated into pandaboard.

OK,

in this case:

Acked-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

	Regards
		Oliver
--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
