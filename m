From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 12/12] tg3: Update version to 3.109
Date: Mon, 5 Apr 2010 13:19:30 -0700
Message-ID: <1270498770-23765-13-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1364 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756467Ab0DEUTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.109.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index af14bcc..763e51f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -67,8 +67,8 @@
 #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
-#define DRV_MODULE_VERSION	"3.108"
-#define DRV_MODULE_RELDATE	"February 17, 2010"
+#define DRV_MODULE_VERSION	"3.109"
+#define DRV_MODULE_RELDATE	"April 2, 2010"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.6.4.4


