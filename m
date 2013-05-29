From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 11/11] net: emaclite: Update driver header
Date: Wed, 29 May 2013 17:33:11 +0200
Message-ID: <c0a6ab3410dd6e6a9198a4605993164700d1b965.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-27676-1369841624-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:38268 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966824Ab3E2Pdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 11:33:47 -0400
Received: by mail-wg0-f49.google.com with SMTP id y10so6844619wgg.16
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 08:33:46 -0700 (PDT)
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-27676-1369841624-0001

Corrent email address and years.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 0d8515b..af12314 100644
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


--=_mimegpg-monstr-desktop-27676-1369841624-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGmH9gACgkQykllyylKDCEjqgCffZYwSfazgY2dbMWKOlBwQlvi
TvgAoJQ/jTISuGiWdU/W23MA6lc1C0YQ
=nNtM
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-27676-1369841624-0001--
