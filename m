From: "Michael Chan" <mchan@broadcom.com>
Subject: [4/4][BNX2]: Update version to 1.6.3.
Date: Mon, 16 Jul 2007 13:07:57 -0700
Message-ID: <1184616477.17688.21.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4070 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756153AbXGPTQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 15:16:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version to 1.6.3.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2dd002b..a729da0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.6.2"
-#define DRV_MODULE_RELDATE	"July 6, 2007"
+#define DRV_MODULE_VERSION	"1.6.3"
+#define DRV_MODULE_RELDATE	"July 16, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


