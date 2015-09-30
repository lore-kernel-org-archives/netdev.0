From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] net: macb: fix two typos
Date: Tue, 29 Sep 2015 19:31:32 -0700
Message-ID: <6195cc372d956bdd3adbf41623ee1645cce30211.1443608885.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:33330 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbbI3Cb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 22:31:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just fix two typos in code comments.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/ethernet/cadence/macb.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 6e1faea..866b128 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -267,9 +267,9 @@
 #define MACB_BEX_SIZE		1
 #define MACB_RM9200_BNQ_OFFSET	4 /* AT91RM9200 only */
 #define MACB_RM9200_BNQ_SIZE	1 /* AT91RM9200 only */
-#define MACB_COMP_OFFSET	5 /* Trnasmit complete */
+#define MACB_COMP_OFFSET	5 /* Transmit complete */
 #define MACB_COMP_SIZE		1
-#define MACB_UND_OFFSET		6 /* Trnasmit under run */
+#define MACB_UND_OFFSET		6 /* Transmit under run */
 #define MACB_UND_SIZE		1
 
 /* Bitfields in RSR */
-- 
1.9.1
