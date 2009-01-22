From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 4/4]bnx2x: Version
Date: Thu, 22 Jan 2009 18:01:37 +0200
Message-ID: <1232640097.29087.56.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Harvey Harrison" <harvey.harrison@gmail.com>,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1556 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbZAVQCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 11:02:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f71b8a5..8b0513b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,8 +57,8 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION	"1.45.24"
-#define DRV_MODULE_RELDATE	"2009/01/14"
+#define DRV_MODULE_VERSION	"1.45.25"
+#define DRV_MODULE_RELDATE	"2009/01/22"
 #define BNX2X_BC_VER		0x040200
 
 /* Time in jiffies before concluding the transmitter is hung */
-- 
1.5.4.3




