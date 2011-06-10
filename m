From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 08/12] e1000e: update driver version
Date: Thu,  9 Jun 2011 20:47:52 -0700
Message-ID: <1307677676-26690-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9764 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754559Ab1FJDsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 23:48:03 -0400
In-Reply-To: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 51cf715..3bf5249 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -54,9 +54,9 @@
 
 #include "e1000.h"
 
-#define DRV_EXTRAVERSION "-k2"
+#define DRV_EXTRAVERSION "-k"
 
-#define DRV_VERSION "1.3.10" DRV_EXTRAVERSION
+#define DRV_VERSION "1.3.16" DRV_EXTRAVERSION
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
-- 
1.7.5.2

