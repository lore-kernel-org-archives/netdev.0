From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH v2 net-next 9/9] be2net: update the driver version to 10.6.0.2
Date: Wed,  6 May 2015 05:30:40 -0400
Message-ID: <1430904640-31918-10-git-send-email-sathya.perla@avagotech.com>
References: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:51843 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752523AbbEFJmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:42:49 -0400
In-Reply-To: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 3e37b59..1eafc07 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -35,7 +35,7 @@
 #include "be_hw.h"
 #include "be_roce.h"
 
-#define DRV_VER			"10.6.0.1"
+#define DRV_VER			"10.6.0.2"
 #define DRV_NAME		"be2net"
 #define BE_NAME			"Emulex BladeEngine2"
 #define BE3_NAME		"Emulex BladeEngine3"
-- 
2.2.0
