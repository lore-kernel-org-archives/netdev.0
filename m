From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 7/7] igb: update version string
Date: Thu, 24 Feb 2011 02:58:29 -0800
Message-ID: <1298545109-8990-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49882 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756113Ab1BXK6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 05:58:37 -0500
In-Reply-To: <1298545109-8990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This will synchronize the version with the out of tree driver which
shares its functionality.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a55fa17..579dbba 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -50,7 +50,7 @@
 #endif
 #include "igb.h"
 
-#define DRV_VERSION "2.1.0-k2"
+#define DRV_VERSION "2.4.13-k2"
 char igb_driver_name[] = "igb";
 char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
-- 
1.7.4

