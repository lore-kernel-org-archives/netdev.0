From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Sat, 26 Nov 2016 18:17:31 +0100
Message-ID: <20161126171730.GA16318@amd>
References: <201611111820.52072@pali>
 <201611221805.13606@pali>
 <20161123222335.GA4788@amd>
 <201611232339.59411@pali>
 <20161124075104.GA26721@amd>
 <20161124083329.GB13735@pali>
 <20161124151317.34yoza3dzuh46oa4@earth>
 <20161124152045.GK13735@pali>
 <20161124184601.wo4al6nyzb6rmiqs@raspberrypi-2.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161124184601.wo4al6nyzb6rmiqs-FnsA7b+Nu9XLHDo1XOr0g3XdqJI7FyRRX3B1VOXEql0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-11-24 20:46:01, Aaro Koskinen wrote:
> Hi,
>=20
> On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Roh=E1r wrote:
> > Proprietary, signed and closed bootloader NOLO does not support DT. So
> > for booting you need to append DTS file to kernel image.
> >=20
> > U-Boot is optional and can be used as intermediate bootloader between
> > NOLO and kernel. But still it has problems with reading from nand, so
> > cannot read NVS data nor MAC address.
>=20
> You could use kexec to pass the fixed DT.

Yeah. You could also strap desktop PC to a USB GPRS card, and call it
phone. You could also make a pig fly.

But because you could does not mean you should. No, sorry, kexec is
not acceptable. Too hard to set up, slows boot too much.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--5vNYLRcllDrimb99
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg5w6oACgkQMOfwapXb+vJqqACgrtAWuiDJlQSlzJga7v8auBQx
iygAoJVSWOy57tYcdiEGo9zizsskhmD/
=9nSs
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--
