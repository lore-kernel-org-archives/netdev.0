From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] ixgbe: Update version to reflect added functionality
Date: Thu, 16 Feb 2017 04:50:30 -0800
Message-ID: <20170216125041.46668-4-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18210 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754477AbdBPMuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:46 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Update the driver version to reflect the new devices that it
supports.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0b73a3607fdd..c1e14a2608ef 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -72,7 +72,7 @@ char ixgbe_default_device_descr[] =
 static char ixgbe_default_device_descr[] =
 			      "Intel(R) 10 Gigabit Network Connection";
 #endif
-#define DRV_VERSION "4.4.0-k"
+#define DRV_VERSION "5.0.0-k"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 				"Copyright (c) 1999-2016 Intel Corporation.";
-- 
2.11.0
