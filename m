From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3][BNX2]: Update version to 1.7.4.
Date: Fri, 22 Feb 2008 11:50:32 -0800
Message-ID: <1203709832.13495.179.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3962 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758355AbYBVTru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 14:47:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Update version to 1.7.4.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 35356fb..15853be 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.3"
-#define DRV_MODULE_RELDATE	"January 29, 2008"
+#define DRV_MODULE_VERSION	"1.7.4"
+#define DRV_MODULE_RELDATE	"February 18, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 


