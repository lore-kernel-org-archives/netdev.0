From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Thu, 3 Mar 2011 13:40:35 +1100
Message-ID: <20110303134035.53cf0296.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__3_Mar_2011_13_40_35_+1100_h_H1da+YW9q49tce"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__3_Mar_2011_13_40_35_+1100_h_H1da+YW9q49tce
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/bnx2x/bnx2x.h between commit
b746f7e52fe33ce66ea0cf6127838eff507839ff ("bnx2x: update driver version
to 1.62.00-6") from the net-current tree and commit
6b28ff3be829a851378551245fd6b3f9bf93b0ad ("bnx2x: Update bnx2x version to
1.62.11-0") from the net tree.

Obvious, really :-)  I used the version from the net tree.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__3_Mar_2011_13_40_35_+1100_h_H1da+YW9q49tce
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNbv+jAAoJEDMEi1NhKgbs/YMH/j5XYeM2mZXfIGAtkaY+3wck
4uw3BZuKV3FT8sOtfhSeBwQZ1Am2UXYt7HyQqFtXWy2NuMSZQM6AyuSTkWVGgR0Z
sFpzpYJCjLNMuBrLTZx0XqGbEUTYzSenvPCOBV+3u+MMjR/sLW4I88lSmDMpikgT
RT1olnqYnLaQtEtxVB4B/u8I3bWJuZkiUPqOh+FO8Zt10Fd+9zIht3YjwV2wmvZK
9LG8Bex2CiHAzQXsauKSws+tnTY4H/nntpEjb9apyt88/Udm0J0KnhYJet14uIfi
CZsUB6RWm4UM0YK53Y3A6dH9LQLY1pdycjr5+KLllc+ThG6zEmdwdacKWsxTqgo=
=X6NZ
-----END PGP SIGNATURE-----

--Signature=_Thu__3_Mar_2011_13_40_35_+1100_h_H1da+YW9q49tce--
