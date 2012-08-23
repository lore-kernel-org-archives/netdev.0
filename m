From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] e1000e: update driver version number
Date: Thu, 23 Aug 2012 02:56:46 -0700
Message-ID: <1345715813-20757-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48088 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932133Ab2HWJ47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:56:59 -0400
In-Reply-To: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index fb42152..e7226b0 100644
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
