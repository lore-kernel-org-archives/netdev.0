From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 8/8] tg3: Update version to 3.110
Date: Mon, 12 Apr 2010 09:58:31 -0700
Message-ID: <1271091511-11173-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4882 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291Ab0DLQ6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.110.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3f8feb1..61089fd 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -67,8 +67,8 @@
 #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
-#define DRV_MODULE_VERSION	"3.109"
-#define DRV_MODULE_RELDATE	"April 2, 2010"
+#define DRV_MODULE_VERSION	"3.110"
+#define DRV_MODULE_RELDATE	"April 9, 2010"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.6.4.4


