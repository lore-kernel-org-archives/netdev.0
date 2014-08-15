From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: dev: remove unused variable from can_calc_bittiming()
 function
Date: Fri, 15 Aug 2014 10:37:17 +0200
Message-ID: <53EDC6BD.6060200@pengutronix.de>
References: <1407399444-16427-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="u6QTOxh7TXJHV5hNdxQ4D5e3T1fw3ToAP"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1407399444-16427-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--u6QTOxh7TXJHV5hNdxQ4D5e3T1fw3ToAP
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/07/2014 10:17 AM, Lad, Prabhakar wrote:
> this patch removes best_rate variable from can_calc_bittiming()
> function which was set but was never used.
>=20
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--u6QTOxh7TXJHV5hNdxQ4D5e3T1fw3ToAP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlPtxr0ACgkQjTAFq1RaXHMZYQCggxNa5yiPtv05eVkZ8KNvnz7s
Z3IAnAhSG4zxlIPIu/db2fcQ0toeJq7i
=6nTI
-----END PGP SIGNATURE-----

--u6QTOxh7TXJHV5hNdxQ4D5e3T1fw3ToAP--
