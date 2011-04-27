From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 10/12] ixgbe: Bump version
Date: Wed, 27 Apr 2011 02:34:49 -0700
Message-ID: <1303896891-16006-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13920 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756071Ab1D0JfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:35:00 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Bump the driver version number to better match up with the out of tree
driver that has similar functionality.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a7da5d9..9160811 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -52,8 +52,8 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
 #define MAJ 3
-#define MIN 2
-#define BUILD 9
+#define MIN 3
+#define BUILD 8
 #define KFIX 2
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
 	__stringify(BUILD) "-k" __stringify(KFIX)
-- 
1.7.4.4

