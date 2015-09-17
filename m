From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v8 0/4] can: Allwinner A10/A20 CAN Controller support -
 Summary
Date: Thu, 17 Sep 2015 22:57:21 +0200
Message-ID: <55FB2931.5090309@pengutronix.de>
References: <1442402482-7118-1-git-send-email-info@gerhard-bertelsmann.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="kHB90vwN9fUSJsw6n1pIq4slgu625POgT"
To: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>,
	wg@grandegger.com, maxime.ripard@free-electrons.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1442402482-7118-1-git-send-email-info@gerhard-bertelsmann.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kHB90vwN9fUSJsw6n1pIq4slgu625POgT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 09/16/2015 01:21 PM, Gerhard Bertelsmann wrote:
> Hi,
>=20
> please find attached the next version of my patch set. I have=20
> taken all remarks from Maxime Ripard into the new version
>=20
> Please review, test and report bugs if exists.
>=20
> The patchset applies to all recent Kernel versions (4.x, next etc.).
>=20
> [PATCH v8 1/4] Device Tree Binding Documentation
> [PATCH v8 2/4] Defconfig multi_v7
> [PATCH v8 3/4] Defconfig sunxi
> [PATCH v8 4/4] Kernel Module

Applies 1 and 4 with maxime's Ack to linux-can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--kHB90vwN9fUSJsw6n1pIq4slgu625POgT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV+ykxAAoJEP5prqPJtc/H8tUIAJMViU7O78lB2NdQDrgLbDVB
mzSFSjwh3AkF2zvYRCqwMbsBdO7rkCEVpE7RyZ68mXxOi0QLAtejRfcfaduoN29A
JpJbFyXz1zA61XgNp15j0LdU/N3FWOvxmasKcynQa6TZoHXUUAqgKl3ZeD0tQvtZ
/DeFnoHbbkyXMmb3w4iYMxknY/r64hvhF3qAZu0fQK2ZiBkTWXsEz/Ffp6Qb1MhR
4beN3G2jxDY8KjzQ7GglEpidd/+LvtkDnERbR/QfGdAa2Gt5qmETaEQtpz1uCLBs
6VKPtRSeO2H65To0e5UrjL230XKxyIYYrXy8KR7DHx0h5l6XY0e/JXPwNwoyx2U=
=F3Aq
-----END PGP SIGNATURE-----

--kHB90vwN9fUSJsw6n1pIq4slgu625POgT--
