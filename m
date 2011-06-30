From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the scsi tree
Date: Thu, 30 Jun 2011 12:33:25 +1000
Message-ID: <20110630123325.43268067.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__30_Jun_2011_12_33_25_+1000_ydD8yP/DmDZB5sPm"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Zolotarov <vladz@broadcom.com>,
	Bhanu Prakash Gollapudi <bprakash@broadcom.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__30_Jun_2011_12_33_25_+1000_ydD8yP/DmDZB5sPm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got conflicts in
drivers/scsi/bnx2fc/bnx2fc.h and drivers/scsi/bnx2fc/bnx2fc_fcoe.c
between commit 2382d2364a60 ("[SCSI] bnx2fc: Bumped version to 1.0.2")
from the scsi tree and commit 619c5cb6885b ("New 7.0 FW: bnx2x, cnic,
bnx2i, bnx2fc") from the net tree.

I used the versions from the net tree as those version numbers were newer.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__30_Jun_2011_12_33_25_+1000_ydD8yP/DmDZB5sPm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOC+B1AAoJEDMEi1NhKgbs+UkIAInMaFaTppuuyQxsV45MXXnW
HpuXdIhRH9hv7mcPgY6u+D7JgbU2IrkhV0y/zdkhhnmr9UcBxv0QkdfclX1MxuTB
0lXdZ7/oLra7AsdpRcuY2Q0QH0zQSPDjqrXH9oOlmj0B+dLX2drg+Y+lk80fLqTT
0z7aRXiVgWAEGpQ057fOdIdpA7ZbkT0FItRZ6QuhF9xDFfUjm6AGCpJGfHiofWBA
MJTnlnYmZeORHf09jYFiZtreO8sOG9Cl2ctczDD4OW5YTvOSEkn4H1PvzyLYUyes
tSIlGU+uX4pMPnpn9RXXWJC4jv0nLf/diufHUR9btueyzPr1V6bbDwMm/wWRZCk=
=uIDP
-----END PGP SIGNATURE-----

--Signature=_Thu__30_Jun_2011_12_33_25_+1000_ydD8yP/DmDZB5sPm--
