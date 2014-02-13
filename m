From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 0/2] Xilinx axi ethernet bug fixes
Date: Thu, 13 Feb 2014 08:10:41 +0100
Message-ID: <cover.1392275432.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-8689-1392275443-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>, monstr@monstr.eu,
	John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-8689-1392275443-0001

Hi,

Based on our discussion I am sending 2 bug fixes for axi ethernet
driver against your net tree.

Thanks,
Michal

Changes in v2:
- Separate bug fixes from features and cleanups

Michal Simek (2):
  net: axienet: Fix compilation error
  net: axienet: Fix compilation warnings

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

--
1.8.2.3


--=_mimegpg-monstr-desktop-8689-1392275443-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL8b/MACgkQykllyylKDCHyCACgjqv47KMKIfebYTiCVTRVOC9q
SN8AniECpoRBPXSvMRsqjkwM4TBevyTp
=pEsV
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-8689-1392275443-0001--
