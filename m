From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 6/6] bnx2: Update version to 1.8.1.
Date: Thu,  9 Oct 2008 10:16:08 -0700
Message-ID: <1223572568-1298-6-git-send-email-mchan@broadcom.com>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3305 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755860AbYJIRKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 13:10:52 -0400
In-Reply-To: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a95ca4f..430d430 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.8.0"
-#define DRV_MODULE_RELDATE	"Aug 14, 2008"
+#define DRV_MODULE_VERSION	"1.8.1"
+#define DRV_MODULE_RELDATE	"Oct 7, 2008"
 
 #define RUN_AT(x) (jiffies + (x))
 
-- 
1.5.6.GIT


