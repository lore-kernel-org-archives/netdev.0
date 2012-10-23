From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbevf: Update version string
Date: Tue, 23 Oct 2012 03:24:47 -0700
Message-ID: <1350987887-16161-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10577 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756037Ab2JWKYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 06:24:55 -0400
In-Reply-To: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 846ac51..07d7eab 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -58,7 +58,7 @@ const char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver";
 
-#define DRV_VERSION "2.6.0-k"
+#define DRV_VERSION "2.7.12-k"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
 	"Copyright (c) 2009 - 2012 Intel Corporation.";
-- 
1.7.11.7
