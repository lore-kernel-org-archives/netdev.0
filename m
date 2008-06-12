From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH]bnx2x: Updating the Maintainer
Date: Thu, 12 Jun 2008 18:02:53 +0300
Message-ID: <1213282973.5995.4.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eliezer Tamir" <eliezert@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3129 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071AbYFLPDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 11:03:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to thank Eliezer Tamir for writing and maintaining the
driver for the past two years. I will take over maintaining the bnx2x
driver from now on.

Thanks,
Eilon

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 MAINTAINERS              |    4 ++--
 drivers/net/bnx2x.c      |    5 +++--
 drivers/net/bnx2x.h      |    3 ++-
 drivers/net/bnx2x_init.h |    3 ++-
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 46fa179..7c8e561 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -995,8 +995,8 @@ L:	netdev@vger.kernel.org
 S:	Supported
 
 BROADCOM BNX2X 10 GIGABIT ETHERNET DRIVER
-P:	Eliezer Tamir
-M:	eliezert@broadcom.com
+P:	Eilon Greenstein
+M:	eilong@broadcom.com
 L:	netdev@vger.kernel.org
 S:	Supported
 
diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 7bdb5af..70cba64 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
  * Slowpath rework by Vladislav Zolotarov
@@ -74,7 +75,7 @@ static char version[] __devinitdata =
 	"Broadcom NetXtreme II 5771X 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
-MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
+MODULE_AUTHOR("Eliezer Tamir");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4f0c0d3..8e68d06 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  */
 
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index dcaecc5..370686e 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -6,7 +6,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Written by: Eliezer Tamir <eliezert@broadcom.com>
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
  */
 
 #ifndef BNX2X_INIT_H
-- 
1.5.3.2




