From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 3/3] net: can: c_can_platform: Remove redundant of_match_ptr
Date: Mon, 30 Sep 2013 10:00:14 +0200
Message-ID: <52492F8E.10708@pengutronix.de>
References: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org> <1380515114-2823-3-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="IBqHWLKl5LEmpdGDJNfiR4L4NvVKj0Ru4"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-can@vger.kernel.org
To: Sachin Kamat <sachin.kamat@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1380515114-2823-3-git-send-email-sachin.kamat@linaro.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IBqHWLKl5LEmpdGDJNfiR4L4NvVKj0Ru4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/30/2013 06:25 AM, Sachin Kamat wrote:
> The data structure of_match_ptr() protects is always compiled in.
> Hence of_match_ptr() is not needed.
>=20
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: linux-can@vger.kernel.org

Applied to linux-can-next/testing, it will be included in my next pull
request to David Miller.

tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--IBqHWLKl5LEmpdGDJNfiR4L4NvVKj0Ru4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJJL44ACgkQjTAFq1RaXHNUDACaA57gz+VnHeEI+Kz+GBNKBKv+
3aEAn1aXjKyDbtpp8vunjC3YDGMgKV85
=WeBT
-----END PGP SIGNATURE-----

--IBqHWLKl5LEmpdGDJNfiR4L4NvVKj0Ru4--
