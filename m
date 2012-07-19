From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 19 Jul 2012 11:15:10 +1000
Message-ID: <20120719111510.478d62e4f0778bd0de1f4c66@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__19_Jul_2012_11_15_10_+1000_.Xf0n7_SldUbmsPL"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Narendra K <narendra_k@dell.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__19_Jul_2012_11_15_10_+1000_.Xf0n7_SldUbmsPL
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c between commit
936597631dd3 ("ixgbevf: Prevent RX/TX statistics getting reset to zero")
from Linus' tree and various commits from the net-next tree.

I just used the version from the net tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__19_Jul_2012_11_15_10_+1000_.Xf0n7_SldUbmsPL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQB1+eAAoJEECxmPOUX5FEAw4P/0oIBajI5br1DTfRou7SH/aS
qjfMvnhdN6sFX/XF/jtmG0JvTQhr2CMwPBXoCdOaMmrzubKA14wbA7abSc/lWDtS
zGrqPxHnxRiTAVLCvYk20Af2YvMJ2qopq64Ixa4PrHQEXcPhzXFeGFUn8lvByDx1
ee6H+ozmCVFbdtQlFCpNv9NMF6HdWLB6WL+ethAKZqRv9fIsi5doJhzu+kk5zoCM
23E444uTIB4OJ7Z+1Rmy8zBh1QghQZR54LhsOhY8nZUrAGUIlFL1ZoLUh2899fVQ
AwEzlhk1SBdtEbDTwOzcKqa4MseYDhRh9g51n6+5R4ASq6j44dTU7ilMMU4ctV2h
1XyiCeoCCZVhDvo3TcckUNPi1WygTQkJRZrWDuo6dDjJd2VnwltViSEWmrux1oJS
qS1kRjKKO6nm9iF9NbEd7HUNVZYDgYLjPzE4bTS8KUU5TI664R265PXOFqibrf7B
8+XC9qrCZ2JDlBZTt19Zq6vRx7T1boiBdJF1so5aP1CW1PpeWpxL6Z4EcNiVm1LW
QwtftFoo9AD7eLdkOa4pRqV5ASGYHEY52O817vnvHr7EVLkbDVZ0wwzM+6dtULhc
goQyKhbGVUn+oB09+CH55eGhengmS+QQMuSgpS7zTMLyM5CyCVjL5L1NHag8/ApT
rXSTaHMJldwJfbiQNqgh
=dRgP
-----END PGP SIGNATURE-----

--Signature=_Thu__19_Jul_2012_11_15_10_+1000_.Xf0n7_SldUbmsPL--
