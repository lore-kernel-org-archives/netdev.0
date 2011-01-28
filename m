From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 7/7] ixgbe: update version string
Date: Thu, 27 Jan 2011 22:18:55 -0800
Message-ID: <1296195535-2990-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34293 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732Ab1A1GTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 01:19:00 -0500
In-Reply-To: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This will synchronize the version string with that of the latest source
forge driver which shares its functionality.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1495b74..83e13a3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -52,7 +52,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 			      "Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "3.0.12-k2"
+#define DRV_VERSION "3.2.9-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static char ixgbe_copyright[] = "Copyright (c) 1999-2010 Intel Corporation.";
 
-- 
1.7.3.5

