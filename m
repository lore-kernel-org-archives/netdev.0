From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 17/17] i40e/i40evf: Bump i40e to 1.3.38 and i40evf to 1.3.25
Date: Mon, 19 Oct 2015 15:49:31 -0700
Message-ID: <1445294971-44714-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49701 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380AbbJSWth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:37 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Bump.

Change-ID: Id0a7ecaa491f88ce94c9eba4901e592a56044ee0
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f0ba384..69e9c3e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -39,7 +39,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 3
-#define DRV_VERSION_BUILD 34
+#define DRV_VERSION_BUILD 38
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index a44a42b..10b2a4a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -34,7 +34,7 @@ char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
 	"Intel(R) XL710/X710 Virtual Function Network Driver";
 
-#define DRV_VERSION "1.3.21"
+#define DRV_VERSION "1.3.25"
 const char i40evf_driver_version[] = DRV_VERSION;
 static const char i40evf_copyright[] =
 	"Copyright (c) 2013 - 2015 Intel Corporation.";
-- 
2.4.3
