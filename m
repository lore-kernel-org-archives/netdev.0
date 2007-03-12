From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 6/6] [TULIP]  Rev tulip version
Date: Mon, 12 Mar 2007 02:31:34 -0700
Message-ID: <20070312184219.205374000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: netdev@vger.kernel.org, Valerie Henson <val_henson@linux.intel.com>
To: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:37894 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751450AbXCLSmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 14:42:16 -0400
Content-Disposition: inline; filename=tulip-rev-version
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rev tulip version... things have changed since 2002!

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/tulip_core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- pristine-linux.orig/drivers/net/tulip/tulip_core.c
+++ pristine-linux/drivers/net/tulip/tulip_core.c
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
