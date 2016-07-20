From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 20/20] fm10k: bump version number
Date: Wed, 20 Jul 2016 15:23:58 -0700
Message-ID: <1469053438-85381-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244AbcGTWYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:09 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index f72d1ca..e9767b6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -28,7 +28,7 @@
 
 #include "fm10k.h"
 
-#define DRV_VERSION	"0.19.3-k"
+#define DRV_VERSION	"0.21.2-k"
 #define DRV_SUMMARY	"Intel(R) Ethernet Switch Host Interface Driver"
 const char fm10k_driver_version[] = DRV_VERSION;
 char fm10k_driver_name[] = "fm10k";
-- 
2.5.5
