From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3][BNX2]: Update version to 1.6.9.
Date: Sun, 09 Dec 2007 13:18:02 -0800
Message-ID: <1197235082.20251.11.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3823 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbXLIUdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Dec 2007 15:33:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Update version to 1.6.9.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f9eea6e..4e7b46e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.6.8"
-#define DRV_MODULE_RELDATE	"October 17, 2007"
+#define DRV_MODULE_VERSION	"1.6.9"
+#define DRV_MODULE_RELDATE	"December 8, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


