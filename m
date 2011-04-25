From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/6] tg3: Update version to 3.118
Date: Mon, 25 Apr 2011 15:42:50 -0700
Message-ID: <1303771370-32579-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4279 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756804Ab1DYWao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 18:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.118.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 696be59..b20538a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,10 +64,10 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			117
+#define TG3_MIN_NUM			118
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"January 25, 2011"
+#define DRV_MODULE_RELDATE	"April 22, 2011"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.7.3.4


