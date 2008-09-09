From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 24/24] ixgbe: bump version
Date: Mon, 08 Sep 2008 21:48:36 -0700
Message-ID: <20080909044836.18904.47079.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:34263 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbYIIEsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:39 -0400
Received: by py-out-1112.google.com with SMTP id p76so1105448pyb.10
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:38 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: None <None>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5efb072..84818fe 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -48,7 +48,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "1.3.18-k4"
+#define DRV_VERSION "1.3.30-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 	 "Copyright (c) 1999-2007 Intel Corporation.";

