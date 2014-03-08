From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] e1000e: Add missing branding strings in ich8lan.c
Date: Sat,  8 Mar 2014 01:25:32 -0800
Message-ID: <1394270741-29926-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39895 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbaCHJZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:46 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Branding strings from recently released and soon to be released
hardware configurations that are supported by e1000e.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 83184cf..723410a 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -46,6 +46,14 @@
  * 82578DC Gigabit Network Connection
  * 82579LM Gigabit Network Connection
  * 82579V Gigabit Network Connection
+ * Ethernet Connection I217-LM
+ * Ethernet Connection I217-V
+ * Ethernet Connection I218-V
+ * Ethernet Connection I218-LM
+ * Ethernet Connection (2) I218-LM
+ * Ethernet Connection (2) I218-V
+ * Ethernet Connection (3) I218-LM
+ * Ethernet Connection (3) I218-V
  */
 
 #include "e1000.h"
-- 
1.8.3.1
