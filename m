From: Suresh Reddy <suresh.reddy@broadcom.com>
Subject: [PATCH net-next 2/2] be2net: Update the driver version to 11.4.0.0
Date: Wed, 24 May 2017 22:24:39 -0400
Message-ID: <1495679079-12025-3-git-send-email-suresh.reddy@broadcom.com>
References: <Suresh.Reddy@broadcom.com>
 <1495679079-12025-1-git-send-email-suresh.reddy@broadcom.com>
Cc: Suresh Reddy <suresh.reddy@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:56950 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932236AbdEYCab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 22:30:31 -0400
In-Reply-To: <1495679079-12025-1-git-send-email-suresh.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 5056624..674cf9d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -37,7 +37,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"11.1.0.0"
+#define DRV_VER			"11.4.0.0"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
1.8.3.1
