From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/14] i40e: Fix function comments
Date: Fri, 14 Mar 2014 16:34:29 -0700
Message-ID: <1394840075-6851-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29252 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756589AbaCNXfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:09 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

Correct misleading function comment.

Change-ID: I3f66cff5cc00250a285756b6500a58fad8eba4b5
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 79be808..63776ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1985,7 +1985,7 @@ static int i40e_vlan_rx_add_vid(struct net_device *netdev,
  * @netdev: network interface to be adjusted
  * @vid: vlan id to be removed
  *
- * net_device_ops implementation for adding vlan ids
+ * net_device_ops implementation for removing vlan ids
  **/
 static int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 				 __always_unused __be16 proto, u16 vid)
-- 
1.8.3.1
