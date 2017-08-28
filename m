From: Pavel Machek <pavel@ucw.cz>
Subject: Re: DSA support for Micrel KSZ8895
Date: Mon, 28 Aug 2017 12:14:52 +0200
Message-ID: <20170828101451.GC18012@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170823090941.GA27570@amd>
 <9235D6609DB808459E95D78E17F2E43D40B05FFF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="jousvV0MzM2p6OtC"
Cc: nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Tristram.Ha@micrel.com,
        andrew@lunn.ch
To: Woojung.Huh@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B05FFF@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jousvV0MzM2p6OtC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > I'll forward your email to our support.
> > > AFAIK, KSZ8895 has different register mapping from KSZ9477,
> > > it will be more than ID changes in current driver.
> >=20
> > More than ID changes, indeed. As layout is completely different, it
> > looks like different source file will be needed for support.
> >=20
> > I'm not nearly there; but I can ifconfig lanX up, already, and perform
> > some pings.
> >=20
> > Any ideas how to do the work in a way to minimize code duplication are
> > welcome...
>=20
> Which version do you use to create patch?
> Getting error when applying patch to the latest net-next.

I'm working at 4.13-rc.

Best regards,
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--jousvV0MzM2p6OtC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmj7RsACgkQMOfwapXb+vL44QCfRTtColsZVOtHGTZrvhGGZ65/
KV4An3aTufFmoii5bJPVrlKd1MJaDK/h
=OSMC
-----END PGP SIGNATURE-----

--jousvV0MzM2p6OtC--
