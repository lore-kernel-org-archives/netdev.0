From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: fix spelling errors
Date: Fri,  2 Mar 2012 18:24:26 -0800
Message-ID: <1330741468-23900-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15473 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259Ab2CCCYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:37 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Correct spelling error caught with codespell.py.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 383b941..87f6b4f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3336,7 +3336,7 @@ static u8 ixgbe_calculate_checksum(u8 *buffer, u32 length)
  *  @hw: pointer to the HW structure
  *  @buffer: contains the command to write and where the return status will
  *           be placed
- *  @lenght: lenght of buffer, must be multiple of 4 bytes
+ *  @length: length of buffer, must be multiple of 4 bytes
  *
  *  Communicates with the manageability block.  On success return 0
  *  else return IXGBE_ERR_HOST_INTERFACE_COMMAND.
-- 
1.7.7.6
