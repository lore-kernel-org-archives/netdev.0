From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the moduleh tree with the net tree
Date: Wed, 28 Sep 2011 17:00:08 +1000
Message-ID: <20110928170008.6d603da5213d16a87b0485c2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__28_Sep_2011_17_00_08_+1000_09XwrI5QSYjBTeyL"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__28_Sep_2011_17_00_08_+1000_09XwrI5QSYjBTeyL
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Paul,

Today's linux-next merge of the moduleh tree got a conflict in
drivers/staging/ath6kl/hif/sdio/linux_sdio/src/hif.c between commit
af2bf4b4ee58 ("staging: remove ath6kl") from the  tree and commit
33cffa3526be ("staging: Add module.h to more drivers implicitly using
it") from the moduleh tree.

The former removed the file, so I did that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__28_Sep_2011_17_00_08_+1000_09XwrI5QSYjBTeyL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOgsX4AAoJEDMEi1NhKgbsOIwH+gODoD1jut/JYSK9WeKLq9UV
rWMVlXIp3d7w46APkfKonwMJez68xNacvTQBEm9iMmgvjWCN839LJ6f2h2f81eND
oBYSzT138IBDXedcCgh89NL2JEXl8CqOfpWgVXAwDSwQpl0DNheP4VxhHViIcGLf
6wFcgOnGAwBD/iW+bH5vjVRyU3ElKDOQjQAo4d0oetFU/3y1jQX64el0WNFJiZmF
0nIED35J2OGCuH7W22V0vtMoRKALKqBmpII32QcdposzyXNVTcNdxVFpFjem4nMl
KH5WCdS16BW07CzR+iR0j3EzxSiyEqPNQsVAdEmFPIo5Fiw/+1Ddmu5lRdXqI0E=
=q2k7
-----END PGP SIGNATURE-----

--Signature=_Wed__28_Sep_2011_17_00_08_+1000_09XwrI5QSYjBTeyL--
