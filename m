From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.24 3/3][BNX2]: Update version to 1.6.6.
Date: Tue, 02 Oct 2007 17:24:06 -0700
Message-ID: <1191371046.5961.33.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3031 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbXJBXZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 19:25:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version to 1.6.6.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c50e4c8..db14f35 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.6.5"
-#define DRV_MODULE_RELDATE	"September 20, 2007"
+#define DRV_MODULE_VERSION	"1.6.6"
+#define DRV_MODULE_RELDATE	"October 2, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


