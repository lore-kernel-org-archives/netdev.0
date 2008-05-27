From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 12/12]bnx2x: Update MAINTAINERS
Date: Tue, 27 May 2008 10:17:46 -0400
Message-ID: <1211897866.6967.85.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eliezer Tamir" <eliezert@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3390 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754878AbYE0OSG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:18:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: Update MAINTAINERS

=EF=BB=BFSigned-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 MAINTAINERS              |    4 ++--
 drivers/net/bnx2x.h      |    3 ++-
 drivers/net/bnx2x_init.h |    3 ++-
 drivers/net/bnx2x_main.c |    5 +++--
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index bc1c008..7738f31 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1002,8 +1002,8 @@ L:	netdev@vger.kernel.org
 S:	Supported
=20
 BROADCOM BNX2X 10 GIGABIT ETHERNET DRIVER
-P:	Eliezer Tamir
-M:	eliezert@broadcom.com
+P:	Eilon Greenstein
+M:	eilong@broadcom.com
 L:	netdev@vger.kernel.org
 S:	Supported
=20
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4fb4962..7cb9cf5 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published b=
y
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  */
=20
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index a01fd8a..42713ff 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published b=
y
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  */
=20
 #ifndef BNX2X_INIT_H
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2031953..3c4837f 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published b=
y
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
  * Slowpath rework by Vladislav Zolotarov
@@ -83,7 +84,7 @@ static char version[] __devinitdata =3D
 	"Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
=20
-MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
+MODULE_AUTHOR("Eliezer Tamir");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
--=20
1.5.5




