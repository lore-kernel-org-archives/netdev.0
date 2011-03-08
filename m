From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 13/14] ixgbe: fix spelling errors
Date: Mon,  7 Mar 2011 18:25:07 -0800
Message-ID: <1299551108-23663-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37667 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755977Ab1CHC0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:07 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 7a6a3fb..bcd9529 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2162,7 +2162,7 @@ out:
  *  @hw: pointer to hardware structure
  *  @mask: Mask to specify which semaphore to acquire
  *
- *  Acquires the SWFW semaphore thought the GSSR register for the specified
+ *  Acquires the SWFW semaphore through the GSSR register for the specified
  *  function (CSR, PHY0, PHY1, EEPROM, Flash)
  **/
 s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
@@ -2210,7 +2210,7 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
  *  @hw: pointer to hardware structure
  *  @mask: Mask to specify which semaphore to release
  *
- *  Releases the SWFW semaphore thought the GSSR register for the specified
+ *  Releases the SWFW semaphore through the GSSR register for the specified
  *  function (CSR, PHY0, PHY1, EEPROM, Flash)
  **/
 void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask)
-- 
1.7.4

