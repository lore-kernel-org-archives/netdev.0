From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] ixgbe: bump version number
Date: Fri,  7 Oct 2011 00:18:34 -0700
Message-ID: <1317971926-23145-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34195 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758536Ab1JGHSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:49 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Bump the version string to better match pair up with the out of tree
driver that contains the same functionality.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1f936c8..1519a23 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -56,8 +56,8 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
 #define MAJ 3
-#define MIN 4
-#define BUILD 8
+#define MIN 6
+#define BUILD 7
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
 	__stringify(BUILD) "-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
-- 
1.7.6.4
