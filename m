From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 8/8][BNX2]: Update version to 1.6.9.
Date: Wed, 12 Dec 2007 11:00:22 -0800
Message-ID: <1197486022.16386.33.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2402 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269AbXLLSPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:15:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Update version to 1.6.9.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ae081c8..469d259 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.6.9"
-#define DRV_MODULE_RELDATE	"December 8, 2007"
+#define DRV_MODULE_VERSION	"1.7.0"
+#define DRV_MODULE_RELDATE	"December 11, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


