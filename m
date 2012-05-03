From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbevf: Update version string
Date: Thu,  3 May 2012 02:56:32 -0700
Message-ID: <1336038992-3144-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49879 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755026Ab2ECJ4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:37 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 5a0e228..f69ec42 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -57,7 +57,7 @@ const char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver";
 
-#define DRV_VERSION "2.2.0-k"
+#define DRV_VERSION "2.6.0-k"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
 	"Copyright (c) 2009 - 2012 Intel Corporation.";
-- 
1.7.7.6
