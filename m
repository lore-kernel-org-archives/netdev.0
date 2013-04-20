From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] igb: Bump version of driver
Date: Sat, 20 Apr 2013 02:49:13 -0700
Message-ID: <1366451353-24714-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14544 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754827Ab3DTJtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 05:49:25 -0400
In-Reply-To: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7eb648b..9d08604 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -60,9 +60,9 @@
 #include <linux/i2c.h>
 #include "igb.h"
 
-#define MAJ 4
-#define MIN 1
-#define BUILD 2
+#define MAJ 5
+#define MIN 0
+#define BUILD 3
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
 __stringify(BUILD) "-k"
 char igb_driver_name[] = "igb";
-- 
1.7.11.7
