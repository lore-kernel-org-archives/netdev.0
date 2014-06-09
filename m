From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] i40evf: Fix function header
Date: Mon,  9 Jun 2014 01:49:07 -0700
Message-ID: <1402303758-1429-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27480 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754214AbaFIItX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 04:49:23 -0400
In-Reply-To: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Fix function header comment to have the correct function name.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e8d2481..af45d0c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1395,7 +1395,7 @@ restart_watchdog:
 }
 
 /**
- * i40evf_configure_rss - increment to next available tx queue
+ * next_queue - increment to next available tx queue
  * @adapter: board private structure
  * @j: queue counter
  *
-- 
1.9.3
