From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] fm10k: bump driver version
Date: Sun, 13 Dec 2015 16:27:38 -0800
Message-ID: <1450052867-36654-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41661 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbbLNA1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:51 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We haven't bumped the driver version in a while despite many fixes being
pulled in from the out-of-tree Sourceforge driver. Update the version to
match.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 1c17b62..df43362 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -28,7 +28,7 @@
 
 #include "fm10k.h"
 
-#define DRV_VERSION	"0.15.2-k"
+#define DRV_VERSION	"0.19.3-k"
 const char fm10k_driver_version[] = DRV_VERSION;
 char fm10k_driver_name[] = "fm10k";
 static const char fm10k_driver_string[] =
-- 
2.5.0
