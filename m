From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 4/4] [TULIP]  Rev tulip version
Date: Mon, 12 Mar 2007 02:59:32 -0700
Message-ID: <20070312095912.743760000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965483AbXCLJ7h@vger.kernel.org>
Content-Disposition: inline; filename=tulip-rev-version
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rev tulip version... things have changed since 2002!

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/tulip_core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- tulip-2.6-mm-linux.orig/drivers/net/tulip/tulip_core.c
+++ tulip-2.6-mm-linux/drivers/net/tulip/tulip_core.c
@@ -17,11 +17,11 @@
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.15-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION	"1.1.14"
+#define DRV_VERSION	"1.1.15"
 #endif
-#define DRV_RELDATE	"May 11, 2002"
+#define DRV_RELDATE	"Feb 27, 2007"
 
 
 #include <linux/module.h>

--
