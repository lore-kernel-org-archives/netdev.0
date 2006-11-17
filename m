From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 17/17][BNX2]: Update version and rel date.
Date: Thu, 16 Nov 2006 19:15:04 -0800
Message-ID: <1163733304.6658.50.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3846 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S1424934AbWKQCWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 21:22:39 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Update version and rel date.

Update version to 1.5.1.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 157463b..fc2f1d1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.4.45"
-#define DRV_MODULE_RELDATE	"September 29, 2006"
+#define DRV_MODULE_VERSION	"1.5.1"
+#define DRV_MODULE_RELDATE	"November 15, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 


