From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: Bump version number
Date: Tue, 13 Jun 2017 17:38:06 -0700
Message-ID: <20170614003810.33189-6-jeffrey.t.kirsher@intel.com>
References: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19685 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753870AbdFNAiW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:22 -0400
In-Reply-To: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Update ixgbe version number.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3ed212f5a43e..c17c8317e001 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -76,7 +76,7 @@ char ixgbe_default_device_descr[] =
 static char ixgbe_default_device_descr[] =
 			      "Intel(R) 10 Gigabit Network Connection";
 #endif
-#define DRV_VERSION "5.0.0-k"
+#define DRV_VERSION "5.1.0-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 				"Copyright (c) 1999-2016 Intel Corporation.";
-- 
2.12.2
