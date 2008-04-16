From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/2] tg3: Update version to 3.91
Date: Wed, 16 Apr 2008 15:27:49 -0700
Message-ID: <20080416222749.GB20272@localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net, "Tony Battersby" <tonyb@cybernetics.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1977 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897AbYDPWZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 18:25:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the version number to 3.91.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 52a44c6..0241c3f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.90"
-#define DRV_MODULE_RELDATE	"April 12, 2008"
+#define DRV_MODULE_VERSION	"3.91"
+#define DRV_MODULE_RELDATE	"April 16, 2008"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


