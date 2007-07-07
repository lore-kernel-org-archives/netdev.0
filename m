From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 9/9][BNX2]: Update version to 1.6.2.
Date: Fri, 06 Jul 2007 20:30:39 -0700
Message-ID: <1183779039.5182.26.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3919 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961AbXGGCiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:38:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version to 1.6.2.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a3ae3b0..c590d8c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.11"
-#define DRV_MODULE_RELDATE	"June 4, 2007"
+#define DRV_MODULE_VERSION	"1.6.2"
+#define DRV_MODULE_RELDATE	"July 6, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


