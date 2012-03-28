From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] ixgbe: update version number
Date: Tue, 27 Mar 2012 23:52:28 -0700
Message-ID: <1332917548-13102-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1125 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761Ab2C1Gwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 02:52:33 -0400
In-Reply-To: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Update the driver version number to better match version of out of tree
driver that has similar functionality.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6dbad2b..3e26b1f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -63,8 +63,8 @@ static char ixgbe_default_device_descr[] =
 			      "Intel(R) 10 Gigabit Network Connection";
 #endif
 #define MAJ 3
-#define MIN 6
-#define BUILD 7
+#define MIN 8
+#define BUILD 21
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
 	__stringify(BUILD) "-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
-- 
1.7.7.6
