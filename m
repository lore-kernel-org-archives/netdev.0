From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next v2 10/10] be2net: bump up the driver version to 11.0.0.0
Date: Mon, 28 Dec 2015 01:49:24 -0500
Message-ID: <1451285364-9074-11-git-send-email-sathya.perla@avagotech.com>
References: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:54935 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751434AbbL1Gtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 01:49:39 -0500
In-Reply-To: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@avagotech.com>

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 8b8212f..22bf7af 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -37,7 +37,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"10.6.0.3"
+#define DRV_VER			"11.0.0.0"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
2.4.1
