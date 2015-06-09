From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: mcp251x: not correct register address
Date: Tue, 9 Jun 2015 09:18:52 +0200
Message-ID: <5576935C.7010905@pengutronix.de>
References: <55698621.7070309@nkgroup.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="lpVWHXV36Lsbp1MjGRmEoa1xGIvc35GT5"
Cc: moorray3@wp.pl, himangi774@gmail.com, netdev@vger.kernel.org
To: Tomas Krcka <tomas.krcka@nkgroup.cz>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55698621.7070309@nkgroup.cz>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lpVWHXV36Lsbp1MjGRmEoa1xGIvc35GT5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/30/2015 11:42 AM, Tomas Krcka wrote:
> v2: fix of corrupted patch
>=20
> This patch corrects addresses of acceptance filters.
> These registers are not in use, but values should be correct.
> Tested with MCP2515 and am3352 and also checked datasheets for MCP2515
> and MCP2510.
>=20
> Signed-off-by: Tomas Krcka <tomas.krcka@nkgroup.cz>=20

Applied to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--lpVWHXV36Lsbp1MjGRmEoa1xGIvc35GT5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJVdpNcAAoJEP5prqPJtc/HKXwIAKhgSa5bDG5dzULw0msJjyte
ydikEx9dm2qA+o2taIT2o9NYaMn81pGPI83A/sTUCIvviU/CepioGiJSr/now5lh
BLBDjyLFl85wmOn7N76/9NUmpInJRtW02euXORNDfKHQKW+trdCyVQvcYpbAeoL1
YUZpn8aI3Hd9VmYKb9WAYgWLrXXtaMfiPxfl2AxT0iDboGuzFWsX610Ixcf1Go9F
gDY8xjwmKY7pd9UNe8KaN1vEKlqfJHpa6p1mbUV9/4SRqHAgz2FXTS9rmQFdtf/H
e6JzqONC4Q+QWmbHz/VFeIwKkswLQDpW+Eu2Ayyw8w74Z/cesdsm2fL5SWQCjGY=
=Z0Tg
-----END PGP SIGNATURE-----

--lpVWHXV36Lsbp1MjGRmEoa1xGIvc35GT5--
