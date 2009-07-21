From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Tue, 21 Jul 2009 22:14:00 +0200
Message-ID: <1248207240.28545.14.camel@violet>
References: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com>
	 <20090721.124217.03326492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090721.124217.03326492.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > Many Nokia handsets support a Phonet interface to the cellular mode=
m
> > via a vendor-specific USB interface. CDC Phonet follows the
> > Communications Device Class model, with one control interface, and
> > and a pair of inactive and active data alternative interface. The l=
ater
> > has two bulk endpoint, one per direction.
> >=20
> > This was tested against Nokia E61, Nokia N95, and the existing Phon=
et
> > gadget function for the Linux composite USB gadget framework.
> >=20
> > Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.=
com>
>=20
> Applied, thanks.

I think that Remi sent an updated version today.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
