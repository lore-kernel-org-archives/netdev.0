From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 9/9][BNX2]: Update version to 1.7.1.
Date: Thu, 20 Dec 2007 12:33:49 -0800
Message-ID: <1198182829.9163.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3907 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921AbXLTTtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:49:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Update version to 1.7.1.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 08b0349..69a3ce3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.0"
-#define DRV_MODULE_RELDATE	"December 11, 2007"
+#define DRV_MODULE_VERSION	"1.7.1"
+#define DRV_MODULE_RELDATE	"December 19, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


