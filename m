From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/18] i40e/i40evf: Bump versions
Date: Sat, 28 Feb 2015 03:29:49 -0800
Message-ID: <1425122989-354-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sravanthi Tangeda <sravanthi.tangeda@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729AbbB1LaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:30:01 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sravanthi Tangeda <sravanthi.tangeda@intel.com>

Bump i40e to 1.2.10 and i40evf to 1.2.4

Change-ID: I48aa64df05fcc8356e7026f3a9e69ecf78d0c785
Signed-off-by: Sravanthi Tangeda <sravanthi.tangeda@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 75b7475..6b04292 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -39,7 +39,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 2
-#define DRV_VERSION_BUILD 9
+#define DRV_VERSION_BUILD 10
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 31d35e2..a951358 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -36,7 +36,7 @@ char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
 	"Intel(R) XL710/X710 Virtual Function Network Driver";
 
-#define DRV_VERSION "1.2.3"
+#define DRV_VERSION "1.2.4"
 const char i40evf_driver_version[] = DRV_VERSION;
 static const char i40evf_copyright[] =
 	"Copyright (c) 2013 - 2014 Intel Corporation.";
-- 
1.9.3
