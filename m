From: Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
Subject: Re: [PATCH v4 0/2] Get and Set Feature Reports on HIDRAW (USB and
 Bluetooth)
Date: Mon, 8 Nov 2010 12:17:15 +0100
Message-ID: <20101108121715.ae2da4af.ospite@studenti.unina.it>
References: <1281442367.12579.206.camel@localhost.localdomain>
	<1281990059-3562-1-git-send-email-alan@signal11.us>
	<alpine.LNX.2.00.1008231459370.1019@pobox.suse.cz>
	<alpine.LNX.2.00.1009021724480.26813@pobox.suse.cz>
	<alpine.LNX.2.00.1009221408330.26813@pobox.suse.cz>
	<alpine.LNX.2.00.1011011523150.15851@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__8_Nov_2010_12_17_15_+0100_wOAKV+vaqM7S8DO7"
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stefan Achatz <erazor_de-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephane Chatty <chatty-rXV5z7KbLFk@public.gmane.org>,
	Michael Poole <mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org>,
	Bastien Nocera <hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1011011523150.15851-ztGlSCb7Y1iN3ZZ/Hiejyg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__8_Nov_2010_12_17_15_+0100_wOAKV+vaqM7S8DO7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 1 Nov 2010 15:23:34 -0400 (EDT)
Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org> wrote:

> On Wed, 22 Sep 2010, Jiri Kosina wrote:
>=20
> > > > > This is version 4. Built against 2.6.35+ revision 320b2b8de12698 .
> > > > >=20
> > > > > Alan Ott (2):
> > > > >   HID: Add Support for Setting and Getting Feature Reports from h=
idraw
> > > > >   Bluetooth: hidp: Add support for hidraw  HIDIOCGFEATURE  and
> > > > >     HIDIOCSFEATURE
[...]
> > > ... Marcel?
> > >=20
> > > I'd really like not to miss 2.6.37 merge window with this.
> >=20
> > Seemingly I have not enought powers to get statement from Marcel here=20
> > these days/weeks.
> >=20
> > Davem, would you perhaps be able to step in here?
>=20
> Marcel, any word on this patchset by chance?
>=20

Hopefully Alan will manage to send a v5 sometime soon, Alan I don't want
to pressure you, just remember to CC Gustavo F. Padovan (see
MAINTAINERS) as he looks to be the most active bluetooth maintainer
these days.

Thanks,
   Antonio

--=20
Antonio Ospite
http://ao2.it

PGP public key ID: 0x4553B001

A: Because it messes up the order in which people normally read text.
   See http://en.wikipedia.org/wiki/Posting_style
Q: Why is top-posting such a bad thing?

--Signature=_Mon__8_Nov_2010_12_17_15_+0100_wOAKV+vaqM7S8DO7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkzX3DsACgkQ5xr2akVTsAEZagCgmarMRB+cv6ZnfEtdAF8ekkkf
/f0Anj1kzzXCG73SZ+dLjuMVQiyQojpe
=6gey
-----END PGP SIGNATURE-----

--Signature=_Mon__8_Nov_2010_12_17_15_+0100_wOAKV+vaqM7S8DO7--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
