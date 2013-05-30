From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 6/6] net: emaclite: Update driver header
Date: Thu, 30 May 2013 12:28:08 +0200
Message-ID: <e00b17108a0c21dd4f74107d78483c32ee5e2445.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-5513-1369909702-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>, renner@efe-gmbh.de,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:40921 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968221Ab3E3K20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:28:26 -0400
Received: by mail-wg0-f53.google.com with SMTP id m15so66365wgh.20
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 03:28:24 -0700 (PDT)
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-5513-1369909702-0001

Correct email address and years.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2:
- s/Corrent/Correct/ in patch description

 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 9227ed7..aa14d8a 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -2,9 +2,9 @@
  * Xilinx EmacLite Linux driver for the Xilinx Ethernet MAC Lite device.
  *
  * This is a new flat driver which is based on the original emac_lite
- * driver from John Williams <john.williams@petalogix.com>.
+ * driver from John Williams <john.williams@xilinx.com>.
  *
- * 2007-2009 (c) Xilinx, Inc.
+ * 2007 - 2013 (c) Xilinx, Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
--
1.8.2.3


--=_mimegpg-monstr-desktop-5513-1369909702-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGnKcYACgkQykllyylKDCGNJACggFJj43tCVFtsxRiXgfrI7rdJ
lOsAnidZEsjMiHzcKAeUiiCJM73aNnkq
=SsIc
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-5513-1369909702-0001--
