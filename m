From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3][BNX2]: Update version to 1.6.7.
Date: Wed, 10 Oct 2007 17:02:10 -0700
Message-ID: <1192060930.6534.6.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1659 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756654AbXJJXCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 19:02:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version to 1.6.7.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 574d043..bbfbdaf 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.6.6"
-#define DRV_MODULE_RELDATE	"October 2, 2007"
+#define DRV_MODULE_VERSION	"1.6.7"
+#define DRV_MODULE_RELDATE	"October 10, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 


