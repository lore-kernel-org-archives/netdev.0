From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net, sja1000: Don't include version.h in peak_pci.c when
 not needed
Date: Mon, 21 Nov 2011 10:51:15 +0100
Message-ID: <4ECA1F13.4080204@pengutronix.de>
References: <alpine.LNX.2.00.1111202204480.17195@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFC063C355B825F3AA1560730"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1111202204480.17195@swampdragon.chaosbits.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFC063C355B825F3AA1560730
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/20/2011 10:07 PM, Jesper Juhl wrote:
> It was pointed out by "make versioncheck" that we do not need to includ=
e
> version.h in drivers/net/can/sja1000/peak_pci.c
> This patch removes the unneeded include.
>=20
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigFC063C355B825F3AA1560730
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7KHxYACgkQjTAFq1RaXHMS/QCfaT5o1gzpvYtEw4CVhOHLbs4Y
NqsAnRIOPuEbu63MLKswXSuOW0PDDjsy
=odzp
-----END PGP SIGNATURE-----

--------------enigFC063C355B825F3AA1560730--
