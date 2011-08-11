From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] e1000e: increase driver version number
Date: Thu, 11 Aug 2011 15:31:48 -0700
Message-ID: <1313101908-11622-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53658 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753832Ab1HKWbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 18:31:53 -0400
In-Reply-To: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c0406b1..362f703 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -56,7 +56,7 @@
 
 #define DRV_EXTRAVERSION "-k"
 
-#define DRV_VERSION "1.3.16" DRV_EXTRAVERSION
+#define DRV_VERSION "1.4.4" DRV_EXTRAVERSION
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
-- 
1.7.6

