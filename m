From: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Thu, 4 Dec 2014 14:11:40 +0300
Message-ID: <20141204111140.GF4979@localhost.localdomain>
References: <20141201111125.GA11974@localhost.localdomain>
 <1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
 <20141201221023.79ffb40d@wiggum>
 <20141202200129.GA4580@crion89>
 <20141202211211.7e08b935@wiggum>
 <547E3BF5.5060201@lwfinger.net>
 <20141203161855.50951aa8@wiggum>
 <20141203161452.GD2896@tuxdriver.com>
 <20141203172315.120040c2@wiggum>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="e5bfZ/T2xnjpUIbw"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Gary.Zambrano@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Michael =?utf-8?B?QsO8c2No?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141203172315.120040c2@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--e5bfZ/T2xnjpUIbw
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 03, 2014 at 05:23:15PM +0100, Michael B=C3=BCsch wrote:

> > > > > That sounds good, indeed.
> > > > > I'd still prefer, if someone with b43 (wireless) would test it, t=
oo.
> > > >=20
> > > > I did a partial test with my PowerBook G4. With the patch installed=
, it would=20
> > > > both suspend and hibernate, but WOL would be impossible. This compu=
ter uses a=20
> > > > PCMCIA version of the BCM4318, and power is turned off to the PCMCI=
A card when=20
> > > > suspended or hibernating.
> > >=20
> > > Thanks for testing.
> > >=20
> > > John, can you take this one? Or do we need to split the b44 part out?
> > > I added my Signed-off.
> >=20
> > Um, sure...3.19 is OK I presume?
>=20
> I think we could even wait for 3.20.
>

Thanks, guys.


--=20
Best regards,
Andrey Skvortsov

PGP Key ID: 0x57A3AEAD

--e5bfZ/T2xnjpUIbw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJUgEFsAAoJEAF8y6L1SLCtyiEP/RWUaBtrdbbiof7rdVOnjpIY
LOZdLyc10hoZfxzcISn/1IOAuqHAW4DnU14VJClxOiu+gGTB/kcm4IcSj9SgV+Kg
FtVrKeayIZvGq1c9GvtwUuYGkrkQheOBO3Utzbb/JWzJiOUA/RP90vLZr5T1ruTR
df0ceqlCaUTDSd/gCmynQRpnf3160QAD0VVD0UILvUp+H9pRVEu91QfFNGvBOXpk
ntUKDrlfatcN4D7GjYA6HaFu8FCef8J7nm7U39FXzuAcNRWUh6dmKJgi1OyBT9du
J6C3V8rlygi/UZBF3qsMMOxCIpKMm27rwi/Eq3YTfwbsDVt1XgdnZbY6yUjj7+ob
HyrOlBF9UicOFn5gGuRe1uaG04iG/53ecPIsw3IRTrrjZGTL81+uolz8OuH/y2vv
aXfmJBQdhIdtIuR72I2O0Ohf5Y4DHXxyVIfIK3wDi0HwgEzct7Z3qeBTRXYRAsiz
g7AWTOuu7nJoOJ+l/IeJj5Yn2JjCEKG+MBCQ0q/N7TGXTNj7KFeYl65cFm8hufVT
QlSaoK8gHydyMDHPk1EFoxLtQHACIWtx5c6hjexUWW8DczJa3yvrKKJpsIrh5u1H
sDnEkQuMfb55+tLG3Azk1q4kA2HupiJME3A3lUVxuiJVjfVamnt1YrYxCwQxylsP
DuVu1UVhqoDBpP6DVHEx
=rWrL
-----END PGP SIGNATURE-----

--e5bfZ/T2xnjpUIbw--
