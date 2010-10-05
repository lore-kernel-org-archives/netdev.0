From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] MAINTAINERS: update Intel LAN Ethernet info
Date: Tue, 05 Oct 2010 04:15:17 -0700
Message-ID: <20101005111438.22968.15130.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:43142 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758118Ab0JELPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 07:15:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Add ixgbevf and docs files to the maintainers file

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 MAINTAINERS |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 44e6595..20a03b9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3050,16 +3050,27 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ixp2000/
 
-INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe)
+INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe/ixgbevf)
 M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
 M:	Jesse Brandeburg <jesse.brandeburg@intel.com>
 M:	Bruce Allan <bruce.w.allan@intel.com>
-M:	Alex Duyck <alexander.h.duyck@intel.com>
+M:	Carolyn Wyborny <carolyn.wyborny@intel.com>
+M:	Don Skidmore <donald.c.skidmore@intel.com>
+M:	Greg Rose <gregory.v.rose@intel.com>
 M:	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
+M:	Alex Duyck <alexander.h.duyck@intel.com>
 M:	John Ronciak <john.ronciak@intel.com>
 L:	e1000-devel@lists.sourceforge.net
 W:	http://e1000.sourceforge.net/
 S:	Supported
+F:	Documentation/networking/e100.txt
+F:	Documentation/networking/e1000.txt
+F:	Documentation/networking/e1000e.txt
+F:	Documentation/networking/igb.txt
+F:	Documentation/networking/igbvf.txt
+F:	Documentation/networking/ixgb.txt
+F:	Documentation/networking/ixgbe.txt
+F:	Documentation/networking/ixgbevf.txt
 F:	drivers/net/e100.c
 F:	drivers/net/e1000/
 F:	drivers/net/e1000e/
@@ -3067,6 +3078,7 @@ F:	drivers/net/igb/
 F:	drivers/net/igbvf/
 F:	drivers/net/ixgb/
 F:	drivers/net/ixgbe/
+F:	drivers/net/ixgbevf/
 
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
 L:	linux-wireless@vger.kernel.org

