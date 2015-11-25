From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/15] i40e: Bump version to 1.4.2
Date: Wed, 25 Nov 2015 10:21:19 -0800
Message-ID: <1448475679-57194-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35528 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852AbbKYSVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 13:21:34 -0500
In-Reply-To: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Bump.

Change-ID: I2d1ce93b2ce74e4eef2394c932aef52cba99713f
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 84b1962..4b7d874 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -38,8 +38,8 @@ static const char i40e_driver_string[] =
 #define DRV_KERN "-k"
 
 #define DRV_VERSION_MAJOR 1
-#define DRV_VERSION_MINOR 3
-#define DRV_VERSION_BUILD 46
+#define DRV_VERSION_MINOR 4
+#define DRV_VERSION_BUILD 2
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
-- 
2.5.0
