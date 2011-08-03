From: Jon Mason <jdmason@kudzu.us>
Subject: [resend PATCH] ixgbe: remove unused #define
Date: Wed,  3 Aug 2011 11:42:53 -0500
Message-ID: <1312389773-9761-2-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:48275 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752Ab1HCQnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 12:43:02 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so339845pzk.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 09:43:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused IXGBE_INTEL_VENDOR_ID #define

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ixgbe/ixgbe_type.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index e0d970e..b5bf2e1 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -32,9 +32,6 @@
 #include <linux/mdio.h>
 #include <linux/netdevice.h>
 
-/* Vendor ID */
-#define IXGBE_INTEL_VENDOR_ID   0x8086
-
 /* Device IDs */
 #define IXGBE_DEV_ID_82598               0x10B6
 #define IXGBE_DEV_ID_82598_BX            0x1508
-- 
1.7.6

