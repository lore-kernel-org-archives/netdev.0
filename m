From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 8/8] bnx2: Update driver version to 1.7.7.
Date: Wed, 18 Jun 2008 17:25:32 -0700
Message-ID: <1213835132-5698-9-git-send-email-mchan@broadcom.com>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3773 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756536AbYFSAXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 20:23:50 -0400
In-Reply-To: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And update module description.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index de4c85e..35cf45a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.6"
-#define DRV_MODULE_RELDATE	"May 16, 2008"
+#define DRV_MODULE_VERSION	"1.7.7"
+#define DRV_MODULE_RELDATE	"June 17, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -68,7 +68,7 @@ static char version[] __devinitdata =
 	"Broadcom NetXtreme II Gigabit Ethernet Driver " DRV_MODULE_NAME " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
-MODULE_DESCRIPTION("Broadcom NetXtreme II BCM5706/5708 Driver");
+MODULE_DESCRIPTION("Broadcom NetXtreme II BCM5706/5708/5709 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
-- 
1.5.5.GIT



