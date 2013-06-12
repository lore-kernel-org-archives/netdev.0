From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/1] net: can: at91_can: Use of_match_ptr()
Date: Wed, 12 Jun 2013 13:47:05 +0200
Message-ID: <51B85FB9.8050907@pengutronix.de>
References: <1371036639-16798-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2FPWDICGBFVVBMURFXSSR"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	davem@davemloft.net, wg@grandegger.com
To: Sachin Kamat <sachin.kamat@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1371036639-16798-1-git-send-email-sachin.kamat@linaro.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2FPWDICGBFVVBMURFXSSR
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 06/12/2013 01:30 PM, Sachin Kamat wrote:
> of_match_ptr() eliminates having an #ifdef returning NULL for the case
> when OF is disabled.
>=20
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>

Tnx, applied to linux-can-next/master.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2FPWDICGBFVVBMURFXSSR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlG4X7wACgkQjTAFq1RaXHMJMgCfXQZv6H8eo7ktMnTa9M1OMgK8
TxMAnRXPEF8BjDgi1MeTyS/22cday2m5
=tlV5
-----END PGP SIGNATURE-----

------enig2FPWDICGBFVVBMURFXSSR--
