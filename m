From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] ixgbe: Remove duplicate and unused device ID definitions
Date: Wed,  4 May 2016 09:26:42 -0700
Message-ID: <1462379208-3997-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:64255 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754377AbcEDQ0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:26:55 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

Remove duplicate and unused device ID definitions.

Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 71082be..1912f7e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -93,12 +93,8 @@
 #define IXGBE_DEV_ID_X550EM_A_SFP	0x15CE
 
 /* VF Device IDs */
-#define IXGBE_DEV_ID_X550_VF_HV	0x1564
-#define IXGBE_DEV_ID_X550_VF		0x1565
-#define IXGBE_DEV_ID_X550EM_X_VF	0x15A8
-#define IXGBE_DEV_ID_X550EM_X_VF_HV	0x15A9
-#define IXGBE_DEV_ID_82599_VF           0x10ED
-#define IXGBE_DEV_ID_X540_VF            0x1515
+#define IXGBE_DEV_ID_82599_VF		0x10ED
+#define IXGBE_DEV_ID_X540_VF		0x1515
 #define IXGBE_DEV_ID_X550_VF		0x1565
 #define IXGBE_DEV_ID_X550EM_X_VF	0x15A8
 #define IXGBE_DEV_ID_X550EM_A_VF	0x15C5
-- 
2.5.5
