From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] net: can: flexcan: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 12:17:10 +0200
Message-ID: <521493A6.6060403@pengutronix.de>
References: <1377080108-33780-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="EPcNfbuTS3CgRLoUKAJCCubxpaQwhT96M"
Cc: wg@grandegger.com, linux-can@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lizefan@huawei.com
To: Libo Chen <libo.chen@huawei.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1377080108-33780-1-git-send-email-libo.chen@huawei.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EPcNfbuTS3CgRLoUKAJCCubxpaQwhT96M
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/21/2013 12:15 PM, Libo Chen wrote:
> Use the wrapper functions for getting and setting the driver data using=

> platform_device instead of using dev_set_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
>=20
> Signed-off-by: Libo Chen <libo.chen@huawei.com>

tnx, applied.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--EPcNfbuTS3CgRLoUKAJCCubxpaQwhT96M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIUk6YACgkQjTAFq1RaXHO6uQCfZCbhJwSxPHY4i8KKrB+hJq1+
7zUAniJGhX37xLtM7v5NlcMXZgRpAT7C
=atNQ
-----END PGP SIGNATURE-----

--EPcNfbuTS3CgRLoUKAJCCubxpaQwhT96M--
