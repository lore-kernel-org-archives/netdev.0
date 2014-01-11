From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 16/17] i40e: Bump version
Date: Fri, 10 Jan 2014 16:47:29 -0800
Message-ID: <1389401250-11509-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64975 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771AbaAKArw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 19:47:52 -0500
In-Reply-To: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Update the driver version to 0.3.28-k.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b4e4da5..ad04da2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -38,7 +38,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 0
 #define DRV_VERSION_MINOR 3
-#define DRV_VERSION_BUILD 27
+#define DRV_VERSION_BUILD 28
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
-- 
1.8.3.1
