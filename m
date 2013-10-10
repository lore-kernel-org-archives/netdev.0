From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] i40e: Bump version
Date: Wed,  9 Oct 2013 23:41:11 -0700
Message-ID: <1381387271-29605-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14054 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059Ab3JJGlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:41:25 -0400
In-Reply-To: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Update the version number of the driver.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 24ee5d4..fbe7fe2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -36,7 +36,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 0
 #define DRV_VERSION_MINOR 3
-#define DRV_VERSION_BUILD 9
+#define DRV_VERSION_BUILD 10
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
-- 
1.8.3.1
