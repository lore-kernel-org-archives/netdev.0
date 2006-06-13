From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 6/6] bnx2: Update version and reldate
Date: Mon, 12 Jun 2006 17:17:22 -0700
Message-ID: <1150157842.26173.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:43026 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932682AbWFMA02
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 20:26:28 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update driver version to 1.4.42.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 3b1fe1e..7cacc3f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.4.40"
-#define DRV_MODULE_RELDATE	"May 22, 2006"
+#define DRV_MODULE_VERSION	"1.4.42"
+#define DRV_MODULE_RELDATE	"June 12, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 


