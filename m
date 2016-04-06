From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40e/i40evf: Bump patch from 1.5.1 to 1.5.2
Date: Tue,  5 Apr 2016 20:36:08 -0700
Message-ID: <1459913769-56510-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60574 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760840AbcDFDga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:30 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d2c0106..d6147f8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -46,7 +46,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 5
-#define DRV_VERSION_BUILD 1
+#define DRV_VERSION_BUILD 2
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 2d1fe56..f4dada0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -38,7 +38,7 @@ static const char i40evf_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 5
-#define DRV_VERSION_BUILD 1
+#define DRV_VERSION_BUILD 2
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD) \
-- 
2.5.5
