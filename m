From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] MAINTAINERS: update for Marvell Ethernet drivers
Date: Mon, 2 Apr 2012 15:59:47 -0700
Message-ID: <20120402155947.7167ef2d@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mirko Lindner <mlindner@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40475 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab2DBXAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2012 19:00:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell has agreed to do maintenance on the sky2 driver.
   * Add the developer to the maintainers file
   * Remove the old reference to the long gone (sk98lin) driver
   * Rearrange to fit current topic organization

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Please hold this patch until ack'd by Mirko.

--- a/MAINTAINERS	2012-04-02 15:51:44.458919901 -0700
+++ b/MAINTAINERS	2012-04-02 15:55:08.311443594 -0700
@@ -4311,6 +4311,13 @@ W:	http://www.kernel.org/doc/man-pages
 L:	linux-man@vger.kernel.org
 S:	Maintained
 
+MARVELL GIGABIT ETHERNET DRIVERS (skge/sky2)
+M:	Mirko Lindner <mlindner@marvell.com>
+M:	Stephen Hemminger <shemminger@vyatta.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/marvell/sk*
+
 MARVELL LIBERTAS WIRELESS DRIVER
 M:	Dan Williams <dcbw@redhat.com>
 L:	libertas-dev@lists.infradead.org
@@ -4341,12 +4348,6 @@ M:	Nicolas Pitre <nico@fluxnic.net>
 S:	Odd Fixes
 F:	drivers/mmc/host/mvsdio.*
 
-MARVELL YUKON / SYSKONNECT DRIVER
-M:	Mirko Lindner <mlindner@syskonnect.de>
-M:	Ralph Roesler <rroesler@syskonnect.de>
-W:	http://www.syskonnect.com
-S:	Supported
-
 MATROX FRAMEBUFFER DRIVER
 L:	linux-fbdev@vger.kernel.org
 S:	Orphan
@@ -6112,12 +6113,6 @@ W:	http://www.winischhofer.at/linuxsisus
 S:	Maintained
 F:	drivers/usb/misc/sisusbvga/
 
-SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
-M:	Stephen Hemminger <shemminger@vyatta.com>
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/ethernet/marvell/sk*
-
 SLAB ALLOCATOR
 M:	Christoph Lameter <cl@linux-foundation.org>
 M:	Pekka Enberg <penberg@kernel.org>
