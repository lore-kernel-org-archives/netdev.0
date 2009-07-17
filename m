From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/4] ixgbe: Bump version number
Date: Thu, 16 Jul 2009 18:51:11 -0700
Message-ID: <20090717015110.24074.85722.stgit@localhost.localdomain>
References: <20090717014951.24074.75893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:34246
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757690AbZGQBv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:51:29 -0400
In-Reply-To: <20090717014951.24074.75893.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Keep the version number marching along as updates come in.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a3bbcfd..79f60e8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -48,7 +48,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
                               "Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "2.0.34-k2"
+#define DRV_VERSION "2.0.37-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static char ixgbe_copyright[] = "Copyright (c) 1999-2009 Intel Corporation.";
 

