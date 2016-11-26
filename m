From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Sat, 26 Nov 2016 18:20:47 +0100
Message-ID: <201611261820.47995@pali>
References: <201611111820.52072@pali> <20161124152045.GK13735@pali> <20161124184601.wo4al6nyzb6rmiqs@raspberrypi-2.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1551961.ahafGneisu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        "linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161124184601.wo4al6nyzb6rmiqs-FnsA7b+Nu9XLHDo1XOr0g3XdqJI7FyRRX3B1VOXEql0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1551961.ahafGneisu
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 24 November 2016 19:46:01 Aaro Koskinen wrote:
> Hi,
>=20
> On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Roh=C3=A1r wrote:
> > Proprietary, signed and closed bootloader NOLO does not support DT.
> > So for booting you need to append DTS file to kernel image.
> >=20
> > U-Boot is optional and can be used as intermediate bootloader
> > between NOLO and kernel. But still it has problems with reading
> > from nand, so cannot read NVS data nor MAC address.
>=20
> You could use kexec to pass the fixed DT.
>=20
> A.

IIRC it was broken for N900/omap3, no idea if somebody fixed it.

=2D-=20
Pali Roh=C3=A1r
pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org

--nextPart1551961.ahafGneisu
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlg5xG8ACgkQi/DJPQPkQ1KHZACePTQRcNym7IEI7ws6eenBNR6t
rEEAn0orVjV+21VfN2jIpBXfChCxrTaW
=lO6H
-----END PGP SIGNATURE-----

--nextPart1551961.ahafGneisu--
