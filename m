From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] i40e: Bump version from 1.5.10 to 1.5.16
Date: Sat, 14 May 2016 21:57:34 -0700
Message-ID: <1463288255-1654-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bimmy Pujari <bimmy.pujari@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbcEOE5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:43 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bimmy Pujari <bimmy.pujari@intel.com>

Signed-off-by: Bimmy Pujari <bimmy.pujari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a981246..1cd0ebf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -46,7 +46,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 5
-#define DRV_VERSION_BUILD 10
+#define DRV_VERSION_BUILD 16
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
-- 
2.5.5
