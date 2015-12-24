From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [net-next PATCH 10/10] be2net: bump up the driver version to 11.0.0.0
Date: Thu, 24 Dec 2015 04:26:32 -0500
Message-ID: <1450949192-4574-11-git-send-email-sathya.perla@avagotech.com>
References: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:64903 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754562AbbLXJn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:43:57 -0500
In-Reply-To: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
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
