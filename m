From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 10/10] r6040: bump release number to 0.18
Date: Sun, 13 Jul 2008 14:36:04 +0200
Message-ID: <200807131436.05324.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:38821 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbYGMMgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:36:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch bumps the release of the r6040 driver. There has been
quite some versions of it out there, but this one is the one
people should report bugs against.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 99dbe46..1cafa92 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -50,8 +50,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.16"
-#define DRV_RELDATE	"10Nov2007"
+#define DRV_VERSION	"0.18"
+#define DRV_RELDATE	"13Jul2008"
 
 /* PHY CHIP Address */
 #define PHY1_ADDR	1	/* For MAC1 */
