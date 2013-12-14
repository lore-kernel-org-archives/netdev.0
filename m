From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 1/9] drivers: net: Remove unused function
 igb_get_eee_status_i354() in e1000_82575.c
Date: Sat, 14 Dec 2013 04:29:22 -0800
Message-ID: <1387024162.2204.101.camel@jtkirshe-mobl>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-n1TkLQ83bPY1pcvcqPoS"
Cc: linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-n1TkLQ83bPY1pcvcqPoS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-14 at 17:44 +0530, Rashika Kheria wrote:
> This patch removes the function igb_get_eee_status_i354() in
> e1000_82575.c because it is unused.
>=20
> It thus eliminates the following warning in
> ethernet/intel/igb/e1000_82575.c:
> drivers/net/ethernet/intel/igb/e1000_82575.c:2591:5: warning: no
> previous prototype for
> =E2=80=98igb_get_eee_status_i354=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.c |   32
> --------------------------
>  1 file changed, 32 deletions(-)

Thanks Rashika, I have added the patch to my queue.

--=-n1TkLQ83bPY1pcvcqPoS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSrE8iAAoJEOVv75VaS+3O96YP/1uitKdatDy2OYjP33qTGKJz
Gdr6B9qry1j7WpLBx5SXrGOjHO6yEhjBwMtYvjQMZxYeFC6hYpGCstbAxO9wYbjU
C4wvCaNJKPklPmCb1Q2IvN+rNWrRP+d1fnxoTMRP37J05TEiP9IDR/rM6GJywhPx
zUeQYPNfJk+fAV1/SZ5cky6xRZLys2OUpSQRu72j5MAonLvhihjL8j0lyHE1aWI6
Pj1OuKjmltO9bSXm/7CLvQ2UuH+ufA++APqeo5KRXH3vGkw6xrAlujp33SqVEO6l
2Ril/BKYm10K1XeJdG6/8LDetIzrAvZ9RVaP06Ucv9Mu5EGV9eKEkHcG59j3jQcQ
i9eZju4GBhf4xwfeZJPpXft4hni2OYiAQxeGHBKBfATknbYT5Vz08cmEcaGyBwOg
oGfk0TPsis1WmoSPdRFLqm4rM+/D1g2RgMLSgTIdn9+A9la+3wGwkYt4wHEuxzpk
l1ZuNjc1xHa7oobfzQLKU+n/iEfjp4rXlFQntx4ZF0+EnIsfQ9tEwnBjyz66yrac
VBwfyeEON9Iw6JcpQnPNvhkxQVRLM5UAiPTV0kZiUEnouKFkkr14IS1lUK6uHaGB
wcDbg9YoLgaGBy64dEwTxtE6vTylqaCWzH12YADc3jv/t/HLii+qPaY7tndHiVh4
JW3U4I1aNPK7lronFelo
=CHdQ
-----END PGP SIGNATURE-----

--=-n1TkLQ83bPY1pcvcqPoS--
