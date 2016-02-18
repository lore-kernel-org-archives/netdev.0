From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e/i40evf: Bump version
Date: Wed, 17 Feb 2016 19:38:57 -0800
Message-ID: <1455766737-11911-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17570 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424710AbcBRDjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:03 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Bump version to i40e-1.4.13 and i40evf-1.4.9

Change-ID: I9db37f9d4899141c3e5455dfb456d45465b8c035
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8bc848f..8d41c6c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -46,7 +46,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 4
-#define DRV_VERSION_BUILD 12
+#define DRV_VERSION_BUILD 13
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index faa1bca..1d81d57 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -38,7 +38,7 @@ static const char i40evf_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 4
-#define DRV_VERSION_BUILD 8
+#define DRV_VERSION_BUILD 9
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD) \
-- 
2.5.0
