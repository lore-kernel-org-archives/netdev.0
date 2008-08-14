From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/4] bnx2: Update version to 1.8.0.
Date: Thu, 14 Aug 2008 15:22:59 -0700
Message-ID: <1218752579-20506-5-git-send-email-mchan@broadcom.com>
References: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2566 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175AbYHNWTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 18:19:20 -0400
In-Reply-To: <1218752579-20506-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1f2e76f..d454810 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.9"
-#define DRV_MODULE_RELDATE	"July 18, 2008"
+#define DRV_MODULE_VERSION	"1.8.0"
+#define DRV_MODULE_RELDATE	"Aug 14, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
-- 
1.5.6.GIT


