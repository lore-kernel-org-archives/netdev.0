From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 6/6] be2net: Update the driver version to 11.1.0.0
Date: Wed,  7 Sep 2016 19:57:54 +0530
Message-ID: <20160907142754.13284-7-sriharsha.basavapatna@broadcom.com>
References: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:51437 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S935769AbcIGOp7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:45:59 -0400
In-Reply-To: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 30a26aa..6cfa63a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -37,7 +37,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"11.0.0.0"
+#define DRV_VER			"11.1.0.0"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
2.10.0.rc2.20.g5b18e70
