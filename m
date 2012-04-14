From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] igb: Update version to 3.4.7.
Date: Sat, 14 Apr 2012 02:16:30 -0700
Message-ID: <1334394991-5839-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16670 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468Ab2DNJQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 05:16:37 -0400
In-Reply-To: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f022ff7..28a37bb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -60,8 +60,8 @@
 #include "igb.h"
 
 #define MAJ 3
-#define MIN 2
-#define BUILD 10
+#define MIN 4
+#define BUILD 7
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
 __stringify(BUILD) "-k"
 char igb_driver_name[] = "igb";
-- 
1.7.7.6
