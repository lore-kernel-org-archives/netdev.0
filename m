From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/6] [BNX2]: Update version to 1.7.5.
Date: Wed, 30 Apr 2008 15:52:20 -0700
Message-ID: <1209595940.7941.65.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, andy@greyhouse.net
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2141 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758649AbYD3VsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 17:48:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Update version to 1.7.5.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 90621c7..252797f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.4"
-#define DRV_MODULE_RELDATE	"February 18, 2008"
+#define DRV_MODULE_VERSION	"1.7.5"
+#define DRV_MODULE_RELDATE	"April 29, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
-- 
1.5.5.GIT



