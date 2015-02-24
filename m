From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/16] i40e/i40evf: Bump Driver Versions
Date: Mon, 23 Feb 2015 18:11:17 -0800
Message-ID: <1424743881-30485-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sravanthi Tangeda <sravanthi.tangeda@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63799 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538AbbBXCLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 21:11:49 -0500
In-Reply-To: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sravanthi Tangeda <sravanthi.tangeda@intel.com>

Bump i40e to 1.2.8 and i40evf to 1.2.2

Change-ID: I64f47c3367ea8ff2a53068e895d7a1f60726c871
Signed-off-by: Sravanthi Tangeda <sravanthi.tangeda@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 163cf2e..d3416a4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -39,7 +39,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 2
-#define DRV_VERSION_BUILD 6
+#define DRV_VERSION_BUILD 8
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4f079e0..b1ca9dd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -36,7 +36,7 @@ char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
 	"Intel(R) XL710/X710 Virtual Function Network Driver";
 
-#define DRV_VERSION "1.2.0"
+#define DRV_VERSION "1.2.2"
 const char i40evf_driver_version[] = DRV_VERSION;
 static const char i40evf_copyright[] =
 	"Copyright (c) 2013 - 2014 Intel Corporation.";
-- 
1.9.3
