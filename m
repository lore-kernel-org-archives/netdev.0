From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 7/8][BNX2X]: update version to 1.42.2
Date: Wed, 20 Feb 2008 19:34:06 +0200
Message-ID: <1203528846.8232.95.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1734 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759633AbYBTReP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 12:34:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: update version to 1.42.2


Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index a213d67..fe96605 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -63,7 +63,7 @@
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
-#define DRV_MODULE_VERSION      "0.40.20"
+#define DRV_MODULE_VERSION      "1.42.2"
 #define DRV_MODULE_RELDATE	"$DateTime: 2008/01/31 07:12:31 $"
 #define BNX2X_BC_VER		0x040200
 
-- 
1.5.3.2




