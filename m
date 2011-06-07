From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 40/40] ixgbevf: Update the driver string
Date: Tue,  7 Jun 2011 05:33:15 -0700
Message-ID: <1307449995-9458-41-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46645 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313Ab1FGMdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:35 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 28d3cb2..b2c5ecd 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -52,7 +52,7 @@ char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver";
 
-#define DRV_VERSION "2.0.0-k2"
+#define DRV_VERSION "2.1.0-k"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
 	"Copyright (c) 2009 - 2010 Intel Corporation.";
-- 
1.7.5.2

