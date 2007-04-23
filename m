From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] update MAINTAINERS for wireless mailing list
Date: Mon, 23 Apr 2007 14:33:34 -0400
Message-ID: <20070423183334.GC5883@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4549 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161404AbXDWSw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 14:52:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch adds the linux-wireless mailing list to all appropriate
entries in the MAINTAINERS file.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 MAINTAINERS |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6876c8b..a15ec1a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -656,6 +656,7 @@ S:	Supported
 ATMEL WIRELESS DRIVER
 P:	Simon Kelley
 M:	simon@thekelleys.org.uk
+L:	linux-wireless@vger.kernel.org
 W:	http://www.thekelleys.org.uk/atmel
 W:	http://atmelwlandriver.sourceforge.net/
 S:	Maintained
@@ -711,6 +712,7 @@ P:	Larry Finger
 M:	Larry.Finger@lwfinger.net
 P:	Stefano Brivio
 M:	st3@riseup.net
+L:	linux-wireless@vger.kernel.org
 W:	http://bcm43xx.berlios.de/
 S:	Maintained
 
@@ -1552,6 +1554,7 @@ S:	Supported
 HOST AP DRIVER
 P:	Jouni Malinen
 M:	jkmaline@cc.hut.fi
+L:	linux-wireless@vger.kernel.org
 L:	hostap@shmoo.com
 W:	http://hostap.epitest.fi/
 S:	Maintained
@@ -1838,6 +1841,7 @@ P:	Yi Zhu
 M:	yi.zhu@intel.com
 P:	James Ketrenos
 M:	jketreno@linux.intel.com
+L:	linux-wireless@vger.kernel.org
 L:	ipw2100-devel@lists.sourceforge.net
 L:	http://lists.sourceforge.net/mailman/listinfo/ipw2100-devel
 W:	http://ipw2100.sourceforge.net
@@ -1848,6 +1852,7 @@ P:	Yi Zhu
 M:	yi.zhu@intel.com
 P:	James Ketrenos
 M:	jketreno@linux.intel.com
+L:	linux-wireless@vger.kernel.org
 L:	ipw2100-devel@lists.sourceforge.net
 L:	http://lists.sourceforge.net/mailman/listinfo/ipw2100-devel
 W:	http://ipw2200.sourceforge.net
@@ -2540,6 +2545,7 @@ P:	Pavel Roskin
 M:	proski@gnu.org
 P:	David Gibson
 M:	hermes@gibson.dropbear.id.au
+L:	linux-wireless@vger.kernel.org
 L:	orinoco-users@lists.sourceforge.net
 L:	orinoco-devel@lists.sourceforge.net
 W:	http://www.nongnu.org/orinoco/
@@ -2719,7 +2725,7 @@ S:	Supported
 PRISM54 WIRELESS DRIVER
 P:	Prism54 Development Team
 M:	developers@islsm.org
-L:	netdev@vger.kernel.org
+L:	linux-wireless@vger.kernel.org
 W:	http://prism54.org
 S:	Maintained
 
@@ -2790,7 +2796,7 @@ S:	Maintained
 RAYLINK/WEBGEAR 802.11 WIRELESS LAN DRIVER
 P:	Corey Thomas
 M:	corey@world.std.com
-L:	linux-kernel@vger.kernel.org
+L:	linux-wireless@vger.kernel.org
 S:	Maintained
 
 RANDOM NUMBER DRIVER
@@ -3053,7 +3059,7 @@ M:	josejx@gentoo.org
 P:	Daniel Drake
 M:	dsd@gentoo.org
 W:	http://softmac.sipsolutions.net/
-L:	netdev@vger.kernel.org
+L:	linux-wireless@vger.kernel.org
 S:	Maintained
 
 SOFTWARE RAID (Multiple Disks) SUPPORT
@@ -3758,6 +3764,7 @@ S:	Maintained
 WAVELAN NETWORK DRIVER & WIRELESS EXTENSIONS
 P:	Jean Tourrilhes
 M:	jt@hpl.hp.com
+L:	linux-wireless@vger.kernel.org
 W:	http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/
 S:	Maintained
 
@@ -3775,6 +3782,7 @@ S:	Maintained
 WL3501 WIRELESS PCMCIA CARD DRIVER
 P:	Arnaldo Carvalho de Melo
 M:	acme@ghostprotocols.net
+L:	linux-wireless@vger.kernel.org
 W:	http://oops.ghostprotocols.net:81/blog
 S:	Maintained
 
@@ -3838,6 +3846,7 @@ M:	dsd@gentoo.org
 P:	Ulrich Kunitz
 M:	kune@deine-taler.de
 W:	http://zd1211.ath.cx/wiki/DriverRewrite
+L:	linux-wireless@vger.kernel.org
 L:	zd1211-devs@lists.sourceforge.net (subscribers-only)
 S:	Maintained
 
-- 
1.5.0.6

-- 
John W. Linville
linville@tuxdriver.com
