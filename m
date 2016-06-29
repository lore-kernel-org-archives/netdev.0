From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40e/i40evf: Bump version from 1.5.16 to 1.6.4
Date: Tue, 28 Jun 2016 21:41:00 -0700
Message-ID: <1467175262-54719-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bimmy Pujari <bimmy.pujari@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62810 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407AbcF2EnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:19 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bimmy Pujari <bimmy.pujari@intel.com>

Signed-off-by: Bimmy Pujari <bimmy.pujari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 880602f..3e394bf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -40,8 +40,8 @@ static const char i40e_driver_string[] =
 #define DRV_KERN "-k"
 
 #define DRV_VERSION_MAJOR 1
-#define DRV_VERSION_MINOR 5
-#define DRV_VERSION_BUILD 16
+#define DRV_VERSION_MINOR 6
+#define DRV_VERSION_BUILD 4
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index da9221b..eac057b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -37,8 +37,8 @@ static const char i40evf_driver_string[] =
 #define DRV_KERN "-k"
 
 #define DRV_VERSION_MAJOR 1
-#define DRV_VERSION_MINOR 5
-#define DRV_VERSION_BUILD 10
+#define DRV_VERSION_MINOR 6
+#define DRV_VERSION_BUILD 4
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD) \
-- 
2.5.5
