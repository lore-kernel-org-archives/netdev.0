From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbe: Bump driver version up
Date: Thu, 04 Feb 2010 22:22:28 -0800
Message-ID: <20100205062227.20910.5719.stgit@localhost.localdomain>
References: <20100205062131.20910.10580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:57051
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932119Ab0BEGWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 01:22:46 -0500
In-Reply-To: <20100205062131.20910.10580.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Driver has gone under significant changes, the version should
reflect that.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ca57e74..c308b59 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -51,7 +51,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
                               "Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "2.0.44-k2"
+#define DRV_VERSION "2.0.62-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static char ixgbe_copyright[] = "Copyright (c) 1999-2010 Intel Corporation.";
 

