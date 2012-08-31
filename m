From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] e1000e: update driver version number
Date: Thu, 30 Aug 2012 22:16:12 -0700
Message-ID: <1346390174-30449-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59105 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227Ab2HaFQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 01:16:42 -0400
In-Reply-To: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c0815ce..095a6be 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -56,7 +56,7 @@
 
 #define DRV_EXTRAVERSION "-k"
 
-#define DRV_VERSION "2.0.0" DRV_EXTRAVERSION
+#define DRV_VERSION "2.1.4" DRV_EXTRAVERSION
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
-- 
1.7.11.4
