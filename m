From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can-next 2013-03-27
Date: Wed, 27 Mar 2013 15:22:24 +0100
Message-ID: <515300A0.2020105@pengutronix.de>
References: <5152FFB8.2000008@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2RAMRFEQMMQXUOBHWTEHO"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5152FFB8.2000008@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2RAMRFEQMMQXUOBHWTEHO
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/27/2013 03:18 PM, Marc Kleine-Budde wrote:
> Hello David,
>=20
> this is a pull-request for net-next/master. It consists of three
> patches by Lars-Peter Clausen to clean up the mcp251x spi-can driver,
> two patches from Ludovic Desroches to bring device tree support to the
> at91_can driver and a patch by me to fix a sparse warning in the
> blackfin driver.
>=20
> regards,
> Marc
>=20
> ---
>=20
> The following changes since commit 6bdeaba47d87f48a3943b6899d6c6e6f17d5=
2f1d:
>=20
>   6lowpan: use IEEE802154_ADDR_LEN instead of a magic number (2013-03-2=
7 00:52:16 -0400)
>=20
> are available in the git repository at:
>=20
>   git@gitorious.org:linux-can/linux-can-next.git testing

Doh! "testing" equals "for-davem" currently and git picked the "wrong"
tree. It should be:

git://gitorious.org/linux-can/linux-can-next.git for-davem

sorry,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2RAMRFEQMMQXUOBHWTEHO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFTAKAACgkQjTAFq1RaXHNPBQCfZQwZ0oKVUR7aMJPOP2ytPdGp
qGYAmwTrKgfGAQQDEtkTLbO6JMGtfoIt
=0+GP
-----END PGP SIGNATURE-----

------enig2RAMRFEQMMQXUOBHWTEHO--
