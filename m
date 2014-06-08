From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e/i40evf: Bump build version
Date: Sun,  8 Jun 2014 07:33:57 -0700
Message-ID: <1402238037-20661-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64930 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562AbaFHOeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:09 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Bump i40e to 0.4.5 and i40evf to 0.9.29.

Change-ID: I9faca5544446518c5425612e733499cf16ef20a1
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8fc554d..8c16e18 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -39,7 +39,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 0
 #define DRV_VERSION_MINOR 4
-#define DRV_VERSION_BUILD 3
+#define DRV_VERSION_BUILD 5
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index edb3b49..e8d2481 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -36,7 +36,7 @@ char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
 	"Intel(R) XL710 X710 Virtual Function Network Driver";
 
-#define DRV_VERSION "0.9.27"
+#define DRV_VERSION "0.9.29"
 const char i40evf_driver_version[] = DRV_VERSION;
 static const char i40evf_copyright[] =
 	"Copyright (c) 2013 - 2014 Intel Corporation.";
-- 
1.9.3
