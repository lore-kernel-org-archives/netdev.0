From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH] net/mlx4: Fix some indent inconsistancy
Date: Sat, 2 Jul 2016 15:54:29 +0300
Message-ID: <20160702125429.GF4750@leon.nu>
References: <1467462665-10191-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dgjlcl3Tl+kb3YDk"
Cc: <yishaih@mellanox.com>, <netdev@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1467462665-10191-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--dgjlcl3Tl+kb3YDk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 02, 2016 at 02:31:05PM +0200, Christophe JAILLET wrote:
> Silent a few smatch warnings about indentation.
> This include the removal of a 'return' statement in 'resource_tracker.c'.
> This 'return' will still be performed when breaking out of the
> corresponding 'switch' block.
>=20
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Thanks
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--dgjlcl3Tl+kb3YDk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXd7mFAAoJEORje4g2clinCrAP/iiQ9gBrH4Hg9eTkJb1lr3NY
CPVnTxRH5twrSOcroxYJr7K6kWIbnpbsWTneyPw22nGhC1gDj8M69bbtrM0V/Fcb
FzQ/khJNFx6q2kd/sRGM6txQBmnPujb2426K+thTk6Es6NZpUTHMwDBjU3AI/xI5
b2533otTsmpFbBPTSeRMl2taBfRsd+2T094IHyJ5VJiwTxHPhv6W0vP4Wsydcl+S
dEBV/fL9pxCiSiZjALhIJboLn1aNuwiuQ2Zbi2qi2RG4j1g4mv1C9xhfRAsE1kKb
UV74N0JRvGily6j6h/ZFtvEjyfPO4n3s2kBowOlZFvmMy685W/wsOwXN+EO2ZIhC
gUUo0C7sREbJ3tQ9fHqFdZ7f5xkWhzcdEJ3RFsFWtehhVh4GHFoSJwqsFrjV1Rf6
WOFiajRYgwLhD7ZKAWpUJ8RS7tNGvH0eV1/W0oVE5kRKa5caB1E14OBGieh3QLkn
1UBpdFB4S8uzwGI806S4TM2z4STGrv8PMP9NJZKvrJR+kuzAD5CbKupTLkqRJVVE
u7F9yc/fdSJYBV/OdMQvfUgWDGgLwXAGiW6kGCkPmgVUuU26B6hHXnGQlDLtlexf
LCye8+avzNAQ3OXHBdDWO/NdnS05hMD3fY/W3mWYNd6mvz3yYU57uxEAvZ8x0vPE
NmA6oUj3JdM+aYa0l+IW
=VG7N
-----END PGP SIGNATURE-----

--dgjlcl3Tl+kb3YDk--
