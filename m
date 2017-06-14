From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbevf: Bump version number
Date: Tue, 13 Jun 2017 17:38:07 -0700
Message-ID: <20170614003810.33189-7-jeffrey.t.kirsher@intel.com>
References: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22692 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753954AbdFNAiX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:23 -0400
In-Reply-To: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Update ixgbevf version number.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index aced91c9c034..084c53582793 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -57,7 +57,7 @@ const char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver";
 
-#define DRV_VERSION "3.2.2-k"
+#define DRV_VERSION "4.1.0-k"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
 	"Copyright (c) 2009 - 2015 Intel Corporation.";
-- 
2.12.2
