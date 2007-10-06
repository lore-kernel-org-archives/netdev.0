From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/4][TG3]: Update version to 3.82.
Date: Fri, 05 Oct 2007 20:38:13 -0700
Message-ID: <1191641893.17453.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1662 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752251AbXJFCjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 22:39:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Update version to 3.82.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2378ea3..b1e5660 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.81"
-#define DRV_MODULE_RELDATE	"September 5, 2007"
+#define DRV_MODULE_VERSION	"3.82"
+#define DRV_MODULE_RELDATE	"October 5, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


