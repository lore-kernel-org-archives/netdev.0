From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/4] e1000e: increase version number
Date: Sat,  5 May 2012 05:38:12 -0700
Message-ID: <1336221493-913-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498Ab2EEMiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2012 08:38:17 -0400
In-Reply-To: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index b53ea83..f648299 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -56,7 +56,7 @@
 
 #define DRV_EXTRAVERSION "-k"
 
-#define DRV_VERSION "1.11.3" DRV_EXTRAVERSION
+#define DRV_VERSION "2.0.0" DRV_EXTRAVERSION
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
-- 
1.7.7.6
