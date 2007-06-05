From: "Michael Chan" <mchan@broadcom.com>
Subject: [5/5][BNX2]: Update version and reldate.
Date: Mon, 04 Jun 2007 17:01:18 -0700
Message-ID: <1181001678.5275.16.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3784 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804AbXFDXRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 19:17:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version and reldate.

Update to version 1.5.11.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 58e6f49..a9b833b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.10"
-#define DRV_MODULE_RELDATE	"May 1, 2007"
+#define DRV_MODULE_VERSION	"1.5.11"
+#define DRV_MODULE_RELDATE	"June 4, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


