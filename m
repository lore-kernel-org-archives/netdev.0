From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 15/18] bnx2x: Whitespace
Date: Mon, 02 Mar 2009 20:01:05 +0200
Message-ID: <1236016865.7723.88.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4409 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756877AbZCBSBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 15/18] bnx2x: Whitespace

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_init.h |    4 ++--
 drivers/net/bnx2x_main.c |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 5362d5a..39ba293 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -186,8 +186,8 @@ static void bnx2x_init_fill(struct bnx2x *bp, u32 addr, int fill, u32 len)
 static void bnx2x_init_wr_64(struct bnx2x *bp, u32 addr, const u32 *data,
 			     u32 len64)
 {
-	u32 buf_len32 = FW_BUF_SIZE/4;
-	u32 len = len64*2;
+	u32 buf_len32 = FW_BUF_SIZE / 4;
+	u32 len = len64 * 2;
 	u64 data64 = 0;
 	int i;
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5397de1..bb9d539 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11048,6 +11048,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	       (bnx2x_get_pcie_speed(bp) == 2) ? "5GHz (Gen2)" : "2.5GHz",
 	       dev->base_addr, bp->pdev->irq);
 	printk(KERN_CONT "node addr %pM\n", dev->dev_addr);
+
 	return 0;
 
 init_one_exit:
-- 
1.5.4.3




