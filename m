From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/5] tg3: Update version to 3.83
Date: Wed, 10 Oct 2007 17:45:27 -0700
Message-ID: <1192063528.4878.187.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3902 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756957AbXJKApe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 20:45:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to version 3.83.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8967bc3..fa8f6c0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.82"
-#define DRV_MODULE_RELDATE	"October 5, 2007"
+#define DRV_MODULE_VERSION	"3.83"
+#define DRV_MODULE_RELDATE	"October 10, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


