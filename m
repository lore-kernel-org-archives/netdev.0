From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: Bump version number
Date: Tue, 17 Dec 2013 22:44:35 -0800
Message-ID: <1387349082-18506-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802Ab3LRGo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:44:57 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Version updated to 0.3.14-k

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 994eb02..da5e8e4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -36,7 +36,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 0
 #define DRV_VERSION_MINOR 3
-#define DRV_VERSION_BUILD 13
+#define DRV_VERSION_BUILD 14
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
-- 
1.8.3.1
