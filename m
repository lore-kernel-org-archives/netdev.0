From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 10/10] tg3: Update version to 3.111
Date: Sat, 5 Jun 2010 20:24:39 -0700
Message-ID: <1275794679-11085-11-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2240 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933999Ab0FFDY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the tg3 version to 3.111.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index eea0748..289cdc5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -67,8 +67,8 @@
 #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
-#define DRV_MODULE_VERSION	"3.110"
-#define DRV_MODULE_RELDATE	"April 9, 2010"
+#define DRV_MODULE_VERSION	"3.111"
+#define DRV_MODULE_RELDATE	"June 5, 2010"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
-- 
1.6.4.4


