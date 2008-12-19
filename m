From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/5] tg3: Update version to 3.97
Date: Thu, 18 Dec 2008 16:56:11 -0800
Message-ID: <1229717362.5508@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1180 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbYLSUJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 15:09:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the version number to 3.97.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 604215f..7971d80 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -67,8 +67,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.96"
-#define DRV_MODULE_RELDATE	"November 21, 2008"
+#define DRV_MODULE_VERSION	"3.97"
+#define DRV_MODULE_RELDATE	"December 10, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.5.6.4


