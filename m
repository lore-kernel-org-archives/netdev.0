From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RESEND next 1/2] net: can: mscan: add a comment on reg
 to idx mapping
Date: Fri, 23 Aug 2013 13:29:06 +0200
Message-ID: <52174782.6080002@pengutronix.de>
References: <1377256144-4173-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="1H2AMXHaxt1NB6iE9Im2p3dGLj8K9Daf6"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Gerhard Sittig <gsi@denx.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Anatolij Gustschin <agust@denx.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1377256144-4173-1-git-send-email-agust@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1H2AMXHaxt1NB6iE9Im2p3dGLj8K9Daf6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/23/2013 01:09 PM, Anatolij Gustschin wrote:
> From: Gerhard Sittig <gsi@denx.de>
>=20
> add a comment about the magic of deriving an MSCAN component index
> from the peripheral's physical address / register offset
>=20
> Cc: linux-can@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Gerhard Sittig <gsi@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Tnx, both applied to linux-can-next/testing. Will be included in the net
pull request to Daivd.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--1H2AMXHaxt1NB6iE9Im2p3dGLj8K9Daf6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIXR4IACgkQjTAFq1RaXHPPHwCfYSGVl71/LTq+vdzM3yGy5Wgo
eOEAoIrraUCmXkU0qcTBXeFG+WpbkB6f
=Xw/e
-----END PGP SIGNATURE-----

--1H2AMXHaxt1NB6iE9Im2p3dGLj8K9Daf6--
