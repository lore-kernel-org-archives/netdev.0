From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [patch] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Wed, 13 Jul 2016 14:29:08 +0300
Message-ID: <20160713112907.GE10079@leon.nu>
References: <20160713100825.GD29468@mwanda>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ffoCPvUAPMgSXi6H"
Cc: Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, <netdev@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160713100825.GD29468@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--ffoCPvUAPMgSXi6H
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 13, 2016 at 01:08:25PM +0300, Dan Carpenter wrote:
> We accidentally return success when we had intended to return an error
> code.
>=20
> Fixes: 69697b6e2086 ('net/mlx5: E-Switch, Add support for the sriov offlo=
ads mode')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks Dan,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--ffoCPvUAPMgSXi6H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXhiYDAAoJEORje4g2clinLZQP/izHp2P94sUzjmAd17y2rdUH
DvLaReGHx5GUlEcNdILzO1ynqDzs/euq4w8pILWTx/R+Wyr0hvdtSRwUMnKLkF2y
1/q6EJUS4rFKEVRdgsv1TmnC1y3ey+BOLCyZ8O7p7I1JswjVBNOR+aCl8c6p4AQv
meY805Z3/TchoBBzzhYaE6nEwVOhPzyrSf3qcOcDxD0dm8CrZEsMOAjEzn3+Aycb
b0kM49MV0tc7oZMvEPqSwiSRUZ66T4PGPTpxmzDe3uN4LZhG2fAK0PY4NMQA6daw
WKZl6SA+MA70eXCLxRDi63n2EM4n0y8wYwJXZXLSHVOGc6HWHCbpbxcEQ9f+zwuQ
JhxWvW3WpluXQH2YXmNyKTmwxyjYknXCP5pN31YG8tSs3PBCMTw3qWHDFJSxv8rb
gpdUmb7iUlnZrjkzq9lEqCoBUfx/j6nKkFag0vL32xyZhzIEqICmJpKvUHhFe4gH
9CHLn4xRJHjbG8FUKaoN0F6Fe+D8Z7D3JlX8YN950bcCe6+7522bhAfvCI1lQA3w
tg46jaBQQi7mqbhGnbCzZcIw5A5hFC3s2xXpWPSj7B1pbGj1jpvUCIgXxGq4U1hG
VcQvY+QvLNBKudO6iTSnWNPEA+izsKcsBYoGCKd0y5mam/nYyQC62v2Ufy4DYOPX
gxpzN1LAg+EaGeJMIYUb
=MLz5
-----END PGP SIGNATURE-----

--ffoCPvUAPMgSXi6H--
