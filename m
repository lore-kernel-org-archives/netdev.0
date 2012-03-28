From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] ixgbe: fix typo in enumeration name
Date: Tue, 27 Mar 2012 23:52:27 -0700
Message-ID: <1332917548-13102-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Xiaojun Zhang <zhangxiaojun@sourceforge.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1117 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050Ab2C1Gwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 02:52:33 -0400
In-Reply-To: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This was pointed out to me by Xiaojun Zhang on Source Forge.

CC: Xiaojun Zhang <zhangxiaojun@sourceforge.net>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 80e26ff..74e1921 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -544,7 +544,7 @@ struct ixgbe_fdir_filter {
 	u16 action;
 };
 
-enum ixbge_state_t {
+enum ixgbe_state_t {
 	__IXGBE_TESTING,
 	__IXGBE_RESETTING,
 	__IXGBE_DOWN,
-- 
1.7.7.6
