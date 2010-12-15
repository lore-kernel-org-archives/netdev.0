From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Wed, 15 Dec 2010 11:45:31 +1100
Message-ID: <20101215114531.bebdc892.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__15_Dec_2010_11_45_31_+1100_8hmpxv4lRrWvzIRs"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vladislav Zolotarov <vladz@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__15_Dec_2010_11_45_31_+1100_8hmpxv4lRrWvzIRs
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/bnx2x/bnx2x.h between commit
9f5449611c9d6d7bdcae8020a197d8b4d9b6443c ("bnx2x: Advance a version
number to 1.60.01-0") from the net-current tree and commit
f404c2fea37e02bec7c8b6edddf5edd22ca60505 ("bnx2x: Update version number
and a date") from the net tree.

So the net tree one has a later date, but a lower version number ... I
just used the version from the net tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__15_Dec_2010_11_45_31_+1100_8hmpxv4lRrWvzIRs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNCA+rAAoJEDMEi1NhKgbs46sH/RTyWMbETb7/aagU9vbYEs/D
/FbBaNUvEkIxwQZUUQ6H/9hwyAwGyAMXEUADSiHtCHBxf8jLcH83Tjq1PpCwVKCV
viNFwgdYSb74gjZpx6fM2bUcGhoorJM/atoPZ35vTRKydzrtmv3s94oDYC8cTiXl
OeAUdIXtPAIhgH8K8TvlHEPnZy0LpNkziZlQabE+/XCt458x7CFNxCd1GGK5IZ6U
u8E8dNRnr/GU5iigVfU7hP3k8qREiS1BI4yBc5sHOUMh8CoIDoNhLjlSTiG0wafw
KIA+OlYibCFjpBKZqyi6n6cenhOav/DkJEhjZqTgBSk4sfk03y1QIRIo/Y5N79Y=
=ydrw
-----END PGP SIGNATURE-----

--Signature=_Wed__15_Dec_2010_11_45_31_+1100_8hmpxv4lRrWvzIRs--
