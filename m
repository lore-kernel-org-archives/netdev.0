From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 17/17] i40e/i40evf: Bump i40e to 1.3.34 and i40evf to 1.3.21
Date: Fri, 16 Oct 2015 05:10:25 -0700
Message-ID: <1444997425-3396-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:58321 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753636AbbJPMKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:33 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Bump.

Change-ID: I7ec818a507554648675b9b245ced9e6b6bd9ed4e
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 722b0a1..87a5d09 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -39,7 +39,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 3
-#define DRV_VERSION_BUILD 28
+#define DRV_VERSION_BUILD 34
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4f3d571..4c4340c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -34,7 +34,7 @@ char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
 	"Intel(R) XL710/X710 Virtual Function Network Driver";
 
-#define DRV_VERSION "1.3.19"
+#define DRV_VERSION "1.3.21"
 const char i40evf_driver_version[] = DRV_VERSION;
 static const char i40evf_copyright[] =
 	"Copyright (c) 2013 - 2015 Intel Corporation.";
-- 
2.4.3
