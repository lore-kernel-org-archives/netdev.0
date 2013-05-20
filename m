From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net/can/mcp251x: Use module_spi_driver to register driver
Date: Mon, 20 May 2013 21:53:31 +0200
Message-ID: <519A7F3B.1000105@pengutronix.de>
References: <1369079399-6031-1-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2BHRVFPFOJSVBFLSSESXQ"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter Huewe <peterhuewe@gmx.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1369079399-6031-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2BHRVFPFOJSVBFLSSESXQ
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/20/2013 09:49 PM, Peter Huewe wrote:
> Removing some boilerplate by using module_spi_driver instead of calling=

> register and unregister in the otherwise empty init/exit functions
>=20
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

A similar patch [1] by Lars-Peter Clausen hit mainline in v3.10-rc1.

thanks, Marc

[1] 01b8807 can: mcp251x: Use module_spi_driver

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2BHRVFPFOJSVBFLSSESXQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGafz8ACgkQjTAFq1RaXHOnPwCeKYOEOM+NtswjyjF5CbgMibLV
2u4An1Bhk6PVqz1Ll+Q7S0tXhATsksSd
=8K45
-----END PGP SIGNATURE-----

------enig2BHRVFPFOJSVBFLSSESXQ--
