From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH can-next v2 0/2] CAN: rcar: add fallback and r8a779[234]
 bindings
Date: Wed, 24 Feb 2016 09:25:20 +0100
Message-ID: <56CD68F0.8090208@pengutronix.de>
References: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="cHH7uxQ2p7IJchfsXxoPfi3pGVvGs02ke"
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cHH7uxQ2p7IJchfsXxoPfi3pGVvGs02ke
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/24/2016 02:56 AM, Simon Horman wrote:
> this series adds fallback bindings for R-Car Gen 1 and Gen 2 SoCs and
> SoC-specific bindings for the r8a779[234] SoCs which are R-Car Gen 2 So=
Cs.
>=20
> The aim is to provide consistent bindings for R-Car Gen 1 and Gen 2
> SoCs in a maner consistent with that progressively being used
> for drivers for other IP blocks used by Renesas SoCs.
>=20
> For changes since v1 see individial patch changelogs.
>=20
> Based on linux-can-next/master

Applied to can-next.

Thanks,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--cHH7uxQ2p7IJchfsXxoPfi3pGVvGs02ke
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWzWjwAAoJED07qiWsqSVqR5EH/Axot9+x7v0qUUpwf6nXmeTY
XmhF8yRKWzTauH7F3Ck6vxNmsChnnLwLn6GUuPzw1q3vE9zfWhtr2rEm5idxgOyA
FgJkU7nGwNJU7LX4cDKuGom/3OByC7KIl3r8N/yKOW5cxjyZR4NsxZrcQJkGz1no
9156598ieWNg76aVcj82yK09tscEM3BvJZEamfzU/0QzZ/vXlIcGpPuBT6NIBjm8
YYMUxxgw5Y4oibm0nRt2Uhh0BhPoXprcMPJtX/b/yI9KSV9c+Y1MlaVB0D8KcbA/
HlkGjzjgEFaUxfuVsBy1Zi8wNAsB53+npSYYMTh8Zo7mUtjT9O29OHINeQ17sB8=
=9bbx
-----END PGP SIGNATURE-----

--cHH7uxQ2p7IJchfsXxoPfi3pGVvGs02ke--
