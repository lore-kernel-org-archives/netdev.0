From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/3] can: mcp251x: Convert to devm-* API
Date: Wed, 13 Nov 2013 10:05:48 +0100
Message-ID: <528340EC.3070908@pengutronix.de>
References: <1384332195-15257-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="lhoKq5OUoF3qkisfbn7dogbaeRiHliX4T"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1384332195-15257-1-git-send-email-shc_work@mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lhoKq5OUoF3qkisfbn7dogbaeRiHliX4T
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2013 09:43 AM, Alexander Shiyan wrote:
> Replace existing resource handling in the driver with managed
> device resource, this ensures more consistent error values and
> simplifies error paths.
>=20
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>

Thanks, looks good.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--lhoKq5OUoF3qkisfbn7dogbaeRiHliX4T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKDQOwACgkQjTAFq1RaXHN5aACeNIeOmgA12Rh948xSIi4h3fnM
VuwAniQnFb4ljM/5JIQYlzg7eXm9ZTTD
=+ISO
-----END PGP SIGNATURE-----

--lhoKq5OUoF3qkisfbn7dogbaeRiHliX4T--
