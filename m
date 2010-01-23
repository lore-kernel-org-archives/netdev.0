From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] MAINTAINERS: Add Intel igbvf maintainer
Date: Sat, 23 Jan 2010 01:15:26 -0800
Message-ID: <20100123091502.10912.25678.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753318Ab0AWJPp@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add igbvf to the list of supported Intel drivers and Alex to the list of
maintainers.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 MAINTAINERS |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ef40d2c..1f0ba17 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2803,10 +2803,11 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ixp2000/
 
-INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/ixgb/ixgbe)
+INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe)
 M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
 M:	Jesse Brandeburg <jesse.brandeburg@intel.com>
 M:	Bruce Allan <bruce.w.allan@intel.com>
+M:	Alex Duyck <alexander.h.duyck@intel.com>
 M:	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
 M:	John Ronciak <john.ronciak@intel.com>
 L:	e1000-devel@lists.sourceforge.net
@@ -2816,6 +2817,7 @@ F:	drivers/net/e100.c
 F:	drivers/net/e1000/
 F:	drivers/net/e1000e/
 F:	drivers/net/igb/
+F:	drivers/net/igbvf/
 F:	drivers/net/ixgb/
 F:	drivers/net/ixgbe/
 
