From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/7][BNX2]: Update version to 1.7.3.
Date: Tue, 29 Jan 2008 16:20:37 -0800
Message-ID: <1201652437.19087.16.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3508 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775AbYA2Xjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 18:39:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Update version to 1.7.3.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7a2a71d..f8bc72e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.2"
-#define DRV_MODULE_RELDATE	"January 21, 2008"
+#define DRV_MODULE_VERSION	"1.7.3"
+#define DRV_MODULE_RELDATE	"January 29, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 


