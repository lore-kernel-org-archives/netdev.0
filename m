From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 1 Mar 2012 13:33:33 +1100
Message-ID: <20120301133333.b8297fbd964c1d7aaf8c9f0b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__1_Mar_2012_13_33_33_+1100_9mP1ssM3ygJLVmta"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__1_Mar_2012_13_33_33_+1100_9mP1ssM3ygJLVmta
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/broadcom/tg3.c between commit 65ec698d1368 ("tg3:
Fix tg3_get_stats64 for 5700 / 5701 devs") from the net tree and various
commits from the net-next tree.

I just used the version from the net-next tree for today (assuming that
this conflict will be fixed shortly).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__1_Mar_2012_13_33_33_+1100_9mP1ssM3ygJLVmta
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPTt/9AAoJEECxmPOUX5FEmUsP/2wPRxWkNxQUXgLO6IkgUpdE
fufy6y2jE7LOGltbPtIXQMzHpWtI+swsO3dsXE7lnAwU1GnP+Plf3l6y9+uKwXYZ
zDjL5FgMLuUzMV5i0tafQsOSpgtpqKy9VCYRFyAQtu2kEOdgrqmauSaKwowcI8En
eDLZnL0NHKDYNyp5h/wGq4k/AxMd2xbN8KjN0gUW+a+kzKFZ2VVwtpUZl0qEjFwJ
1t/kzQVrUAr7NoICHFSrUUHOOpOFfywCWoKUbwevo20Zz9w9f6cwf6qo3PmKk5uN
H78ljwrPsfJ2+/2G0PfLk7Np4KtUux9ZZqiOJIbMaRSlmdeuYvL0wnD7t5hwWMF3
qUe/2sFA7ryQQqWRxwn+XVeDN9+pPRSJnkDOEjWMjofFgryrgL1n36DjVBBmcdKW
fH9Yp+OINuGF9OQyLxB2NEgemb1Z4Ku/1cnvsYCulWaW0qQvSX7i5GNIFOkPKV4T
LGueq3nMtqAbaSxfzfHNIfPcTlebXRbLYMMVK/IAVLCU4ICM59dOor/PQaKwqtWH
81wRH760xoA7n8PpU1eSMB4adSMmNvAk9gHHDDF6HIa+KgEiAaiZJS4q6wMvcm5t
XL4juQ8igEXemDGfyIJ8TQ6f8sPirlfnpbPzB89uofz4mE+6FyHcLNJhikQEakKH
UhZKt380aXnVufRO+StJ
=H2L+
-----END PGP SIGNATURE-----

--Signature=_Thu__1_Mar_2012_13_33_33_+1100_9mP1ssM3ygJLVmta--
