From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/12] i40e/i40evf: Change version from 1.6.27 to 2.1.7
Date: Wed, 15 Mar 2017 02:25:44 -0700
Message-ID: <20170315092545.63654-12-jeffrey.t.kirsher@intel.com>
References: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Cc: Bimmy Pujari <bimmy.pujari@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44457 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751694AbdCOJ0H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 05:26:07 -0400
In-Reply-To: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bimmy Pujari <bimmy.pujari@intel.com>

Signed-off-by: Bimmy Pujari <bimmy.pujari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 6 +++---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 414685c683d7..4d305fb1f188 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -39,9 +39,9 @@ static const char i40e_driver_string[] =
 
 #define DRV_KERN "-k"
 
-#define DRV_VERSION_MAJOR 1
-#define DRV_VERSION_MINOR 6
-#define DRV_VERSION_BUILD 27
+#define DRV_VERSION_MAJOR 2
+#define DRV_VERSION_MINOR 1
+#define DRV_VERSION_BUILD 7
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 9492b20da557..6d666bde9df5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -37,9 +37,9 @@ static const char i40evf_driver_string[] =
 
 #define DRV_KERN "-k"
 
-#define DRV_VERSION_MAJOR 1
-#define DRV_VERSION_MINOR 6
-#define DRV_VERSION_BUILD 27
+#define DRV_VERSION_MAJOR 2
+#define DRV_VERSION_MINOR 1
+#define DRV_VERSION_BUILD 7
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD) \
-- 
2.12.0
