From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 09/10] [TULIP] Update tulip version
Date: Fri, 25 Aug 2006 17:02:36 -0700
Message-ID: <20060826000304.507563000@linux.intel.com>
References: <20060826000227.818796000@linux.intel.com>
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:59488 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1422932AbWHZADH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 20:03:07 -0400
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline; filename=tulip-rev-tulip-version
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/tulip_core.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/tulip_core.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/tulip_core.c
@@ -17,11 +17,11 @@
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.15-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION	"1.1.14"
+#define DRV_VERSION	"1.1.15"
 #endif
-#define DRV_RELDATE	"May 6, 2006"
+#define DRV_RELDATE	"Aug 23, 2006"
 
 
 #include <linux/module.h>

--
