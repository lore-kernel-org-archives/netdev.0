From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 3/6] can: sja1000: platform: use devm_* APIs
Date: Fri, 31 Jan 2014 13:34:03 +0100
Message-ID: <52EB983B.70602@pengutronix.de>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch> <1391164513-11529-4-git-send-email-florian.vaussard@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="fvPK7h6N2bVOfijUMCoGIjjFrwopFiNn5"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Vaussard <florian.vaussard@epfl.ch>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391164513-11529-4-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fvPK7h6N2bVOfijUMCoGIjjFrwopFiNn5
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/31/2014 11:35 AM, Florian Vaussard wrote:
> Simplify probe and remove functions by converting most of the resources=

> to use devm_* APIs.
>=20
> Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>

Looks good.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fvPK7h6N2bVOfijUMCoGIjjFrwopFiNn5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLrmDsACgkQjTAFq1RaXHMa6wCePt5blOzuVcw5bWtzbkSr+y8R
z2AAn1vog0KlU0ntSRZFc0TjdHlNN5JZ
=FHOG
-----END PGP SIGNATURE-----

--fvPK7h6N2bVOfijUMCoGIjjFrwopFiNn5--
