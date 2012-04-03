From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Wed, 4 Apr 2012 08:37:38 +1000
Message-ID: <20120404083738.0b0f09ffc1f8c5a105c240eb@canb.auug.org.au>
References: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com>
	<20120403.182335.782073108961783777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__4_Apr_2012_08_37_38_+1000_c_PMc6Vmw+gayM8Z"
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403.182335.782073108961783777.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__4_Apr_2012_08_37_38_+1000_c_PMc6Vmw+gayM8Z
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 03 Apr 2012 18:23:35 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> Format the comment:
>=20
> 	/* Like
> 	 * this.
> 	 */
>=20
> not:
>=20
> 	/*
> 	 * Like
> 	 * this.
> 	 */

People may be confused because Documentation/CodingStyle says to use the
latter ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__4_Apr_2012_08_37_38_+1000_c_PMc6Vmw+gayM8Z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPe3uyAAoJEECxmPOUX5FEQMAP/iu3VXzOK9OlAv0GnGjaoRin
M2x8PMlqVVdLVa2W/stXMowmFu7ItvD0EAKhH1vmaGVSGJd6IN/TKoxINqudp//u
xf1kpQOT2GHhV0riJtv5yy/gBLXvR+NPtTSP2uEzst1zNo5jlwqfWVBNMo9epkyw
2CCktmpoaYTyuG4cu0W5y1z+rTmPuhGQo3nNQoWzpoV4u9PM2ESU/xuN5GScUbit
dYD+udLo0O3wzU2DUUgRT6zOsZfoHq1ueeWVoyVDb4TGTI2pda25JlgTz9VQybM2
2RHgOHzl3QhGUpukF7b8HG7Jft5qMYrvZbCfgBQO/6QJA+aGHd7bOPXOsxTGuLsd
gfnZIhyuscqzWGjz3MJwAeSFruplWsUuo2s8ocvRz204gaaSXJeRgrSN5fCQnoGD
XTmq5tMtxF9SoDZxhPTTdtKcAFU65dIsjSkzrZA9n9J4i7LPQgP0btzpz9Po5Qh+
pnwTN83B2PGq1gdf4NzF7oUOmj3m0lahDf6YfU56s8i3HFRqnBWXqfULeYNZoh+N
vKBeu+wU7f9anSv3He8gfQXR7Goz86lQEB2WbP5pnXXAP/kDKtenzT1uOGbjdGrZ
fgI6tkncdWRh+lW6kF6jjh3WtCW3M+Ls5ZNAbDgiUP2Yshh/E97FCuAsjIZ7dphH
VmzBEinNWP6lBe1lYUCf
=WFi7
-----END PGP SIGNATURE-----

--Signature=_Wed__4_Apr_2012_08_37_38_+1000_c_PMc6Vmw+gayM8Z--
