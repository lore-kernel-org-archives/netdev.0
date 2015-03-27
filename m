From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] i40e: Bump version to 1.2.43
Date: Fri, 27 Mar 2015 03:02:53 -0700
Message-ID: <1427450573-13945-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13066 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207AbbC0KDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 06:03:22 -0400
In-Reply-To: <1427450573-13945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Bump.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 048d8ec..845bcee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -39,7 +39,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 1
 #define DRV_VERSION_MINOR 2
-#define DRV_VERSION_BUILD 37
+#define DRV_VERSION_BUILD 43
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
-- 
1.9.3
