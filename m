From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 8/8] tg3: Update version to 3.115
Date: Thu, 14 Oct 2010 13:37:45 -0700
Message-ID: <1287088665-22135-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2371 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756007Ab0JNUiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:38:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.115.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5d30e67..5b4c510 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,10 +69,10 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			114
+#define TG3_MIN_NUM			115
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"September 30, 2010"
+#define DRV_MODULE_RELDATE	"October 14, 2010"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.7.2.2


