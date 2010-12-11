From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 26/27] e1000e: increment the driver version
Date: Fri, 10 Dec 2010 22:20:39 -0800
Message-ID: <1292048440-22125-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048440-22125-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:49839 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751914Ab0LKGUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:20:50 -0500
To: davem@davemloft.net
In-Reply-To: <1292048440-22125-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 6e1f3a3..5530d0b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -54,7 +54,7 @@
 
 #define DRV_EXTRAVERSION "-k2"
 
-#define DRV_VERSION "1.2.7" DRV_EXTRAVERSION
+#define DRV_VERSION "1.2.20" DRV_EXTRAVERSION
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
-- 
1.7.3.2

