From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 24/29] ixgbe: bump version
Date: Thu, 11 Sep 2008 20:03:55 -0700
Message-ID: <20080912030339.6234.577.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:44217 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbYILDD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:03:58 -0400
Received: by wa-out-1112.google.com with SMTP id j37so394015waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:03:57 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 41aede5..b513911 100644
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

