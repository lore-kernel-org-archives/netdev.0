From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 4/4] bnx2x: driver version 1.48.105-1
Date: Wed, 22 Apr 2009 16:40:32 +0300
Message-ID: <1240407632.18871.50.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com,
	"John Wright" <john.wright@hp.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3582 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753686AbZDVNni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 09:43:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0ed1ced..d976dd4 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -56,8 +56,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.48.105"
-#define DRV_MODULE_RELDATE	"2009/03/02"
+#define DRV_MODULE_VERSION	"1.48.105-1"
+#define DRV_MODULE_RELDATE	"2009/04/22"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
-- 
1.6.1.3




