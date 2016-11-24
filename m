From: Pavel Machek <pavel@ucw.cz>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 08:51:04 +0100
Message-ID: <20161124075104.GA26721@amd>
References: <201611111820.52072@pali>
 <201611221805.13606@pali>
 <20161123222335.GA4788@amd>
 <201611232339.59411@pali>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Cc: Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201611232339.59411@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > "ifconfig hw ether XX" normally sets the address. I guess that's
> > ioctl?
>=20
> This sets temporary address and it is ioctl. IIRC same as what ethtool=20
> uses. (ifconfig is already deprecated).
>=20
> > And I guess we should use similar mechanism for permanent
> > address.
>=20
> I'm not sure here... Above ioctl =E2=86=91=E2=86=91=E2=86=91 is for chang=
ing temporary mac=20
> address. But here we do not want to change permanent mac address. We=20
> want to tell kernel driver current permanent mac address which is
> stored

Well... I'd still use similar mechanism :-).
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg2m+gACgkQMOfwapXb+vKdTACgmqIMZEMe0mifTbptRfXmAGMs
ioQAnRac8nGiIzkUhJyJ3dZKrfjvcGd7
=ueN4
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
