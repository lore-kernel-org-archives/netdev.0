From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 3/3] tg3: update version and reldate
Date: Fri, 26 May 2006 16:03:16 -0700
Message-ID: <1148684596.3930.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:57870 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751749AbWE0AnK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 20:43:10 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update version to 3.59.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b01499c..db3f769 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.58"
-#define DRV_MODULE_RELDATE	"May 22, 2006"
+#define DRV_MODULE_VERSION	"3.59"
+#define DRV_MODULE_RELDATE	"May 26, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0


