From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 14/14] tg3: Update version to 3.113
Date: Mon, 2 Aug 2010 14:26:08 -0700
Message-ID: <1280784368-4226-14-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2868 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755449Ab0HBV0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.113.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a9d61ab..bc3af78 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,10 +69,10 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			112
+#define TG3_MIN_NUM			113
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"July 11, 2010"
+#define DRV_MODULE_RELDATE	"August 2, 2010"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.7.1


