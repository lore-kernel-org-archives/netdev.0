From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] e1000e: Increase driver version number
Date: Wed,  5 Aug 2015 16:52:15 -0700
Message-ID: <1438818735-38115-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:40422 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740AbbHEXwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:23 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 96a8166..546b5da 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -48,7 +48,7 @@
 
 #define DRV_EXTRAVERSION "-k"
 
-#define DRV_VERSION "3.2.5" DRV_EXTRAVERSION
+#define DRV_VERSION "3.2.6" DRV_EXTRAVERSION
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
-- 
2.4.3
