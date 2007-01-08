From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2 4/4]: Update version and reldate.
Date: Mon, 08 Jan 2007 15:56:57 -0800
Message-ID: <1168300618.4430.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3086 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161188AbXAHXKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 18:10:07 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version and reldate.

Update version to 1.5.3.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 08a77a3..6494f5b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.2"
-#define DRV_MODULE_RELDATE	"December 13, 2006"
+#define DRV_MODULE_VERSION	"1.5.3"
+#define DRV_MODULE_RELDATE	"December 8, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 


