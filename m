From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH] net/fsl: fix misspelled word
Date: Tue, 29 Jul 2014 14:47:25 -0500
Message-ID: <1406663245-8781-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Madalin Bucur <madalin.bucur@Freescale.com>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0186.outbound.protection.outlook.com ([207.46.163.186]:30883
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751212AbaG2Trc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 15:47:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@freescale.com>

Fix one misspelled word reported by codespell.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
Signed-off-by: Shruti Kanetkar <Shruti@freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 0c9d55c..8173407 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -46,7 +46,7 @@ struct tgec_mdio_controller {
 #define MDIO_DATA_BSY		(1 << 31)
 
 /*
- * Wait untill the MDIO bus is free
+ * Wait until the MDIO bus is free
  */
 static int xgmac_wait_until_free(struct device *dev,
 				 struct tgec_mdio_controller __iomem *regs)
-- 
1.8.3.1
