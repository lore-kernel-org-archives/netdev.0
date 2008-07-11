From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 6/6] bnx2: Update version to 1.7.8.
Date: Thu, 10 Jul 2008 18:29:15 -0700
Message-ID: <1215739755-5495-6-git-send-email-mchan@broadcom.com>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Michael Chan" <mchan@braodcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1735 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756548AbYGKB0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 21:26:24 -0400
In-Reply-To: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@braodcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0d0bb93..9ce30fc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.7.7"
-#define DRV_MODULE_RELDATE	"June 17, 2008"
+#define DRV_MODULE_VERSION	"1.7.8"
+#define DRV_MODULE_RELDATE	"July 10, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
-- 
1.5.5.GIT


