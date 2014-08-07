From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Update FW version string to match FW binary version
Date: Thu,  7 Aug 2014 14:38:51 +0530
Message-ID: <1407402531-14283-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:35626
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754072AbaHGJDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 05:03:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index c9b922c..cc42ab3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -50,13 +50,13 @@
 #include "cxgb4_uld.h"
 
 #define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x09
-#define T4FW_VERSION_MICRO 0x17
+#define T4FW_VERSION_MINOR 0x0B
+#define T4FW_VERSION_MICRO 0x1B
 #define T4FW_VERSION_BUILD 0x00
 
 #define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x09
-#define T5FW_VERSION_MICRO 0x17
+#define T5FW_VERSION_MINOR 0x0B
+#define T5FW_VERSION_MICRO 0x1B
 #define T5FW_VERSION_BUILD 0x00
 
 #define CH_WARN(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ## __VA_ARGS__)
-- 
1.7.1
