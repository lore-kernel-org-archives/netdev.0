From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 4/4] b44: update version to 1.01
Date: Wed, 24 May 2006 07:40:53 -0700
Message-ID: <1148481653.2976.56.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:59663 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932768AbWEXVmo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 17:42:44 -0400
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 6eea1fc..f72a591 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -29,8 +29,8 @@

 #define DRV_MODULE_NAME		"b44"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.00"
-#define DRV_MODULE_RELDATE	"Apr 7, 2006"
+#define DRV_MODULE_VERSION	"1.01"
+#define DRV_MODULE_RELDATE	"May 24, 2006"

 #define B44_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \


