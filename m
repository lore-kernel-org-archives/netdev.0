From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/5] bnx2: Update version to 1.8.2.
Date: Wed, 12 Nov 2008 15:10:04 -0800
Message-ID: <1226531404-26118-5-git-send-email-mchan@broadcom.com>
References: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2683 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbYKLXDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 18:03:47 -0500
In-Reply-To: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 84563b0..0853b3c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.8.1"
-#define DRV_MODULE_RELDATE	"Oct 7, 2008"
+#define DRV_MODULE_VERSION	"1.8.2"
+#define DRV_MODULE_RELDATE	"Nov 10, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
-- 
1.5.6.GIT


