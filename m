From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 5/6 resend] b44: update version to 1.01
Date: Tue, 20 Jun 2006 15:34:40 -0700
Message-ID: <1150842880.21197.57.camel@dhcp-10-7-81-7.broadcom.com>
References: <1150485570.8716.54.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:60678 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751427AbWFTWfS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 18:35:18 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <1150485570.8716.54.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the driver version to 1.01

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 98c0675..a7e4ba5 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -29,8 +29,8 @@
 
 #define DRV_MODULE_NAME		"b44"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.00"
-#define DRV_MODULE_RELDATE	"Apr 7, 2006"
+#define DRV_MODULE_VERSION	"1.01"
+#define DRV_MODULE_RELDATE	"Jun 16, 2006"
 
 #define B44_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \


