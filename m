From: Urs Thuermann <urs.thuermann@gmx.de>
Subject: [PATCH 6/7] CAN: Add maintainer entries
Date: Fri, 16 Nov 2007 16:02:51 +0100
Message-ID: <20071116150557.28784.6@janus.isnogud.escape.de>
References: <20071116150245.28784.0@janus.isnogud.escape.de>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Joe Perches <joe@perches.com>, Sam Ravnborg <sam@ravnborg.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:46271 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933160AbXKPPL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 10:11:26 -0500
Content-Disposition: inline; filename=06-can-maintainers.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds entries in the CREDITS and MAINTAINERS file for CAN.

Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>

---
 CREDITS     |   16 ++++++++++++++++
 MAINTAINERS |    9 +++++++++
 2 files changed, 25 insertions(+)

Index: net-2.6.25/CREDITS
===================================================================
--- net-2.6.25.orig/CREDITS	2007-11-14 13:04:23.000000000 +0100
+++ net-2.6.25/CREDITS	2007-11-14 13:04:55.000000000 +0100
@@ -1353,6 +1353,14 @@
 S: 5623 HZ Eindhoven
 S: The Netherlands
 
+N: Oliver Hartkopp
+E: oliver.hartkopp@volkswagen.de
+W: http://www.volkswagen.de
+D: Controller Area Network (network layer core)
+S: Brieffach 1776
+S: 38436 Wolfsburg
+S: Germany
+
 N: Andrew Haylett
 E: ajh@primag.co.uk
 D: Selection mechanism
@@ -3306,6 +3314,14 @@
 S: F-35042 Rennes Cedex
 S: France
 
+N: Urs Thuermann
+E: urs.thuermann@volkswagen.de
+W: http://www.volkswagen.de
+D: Controller Area Network (network layer core)
+S: Brieffach 1776
+S: 38436 Wolfsburg
+S: Germany
+
 N: Jon Tombs
 E: jon@gte.esi.us.es
 W: http://www.esi.us.es/~jon
Index: net-2.6.25/MAINTAINERS
===================================================================
--- net-2.6.25.orig/MAINTAINERS	2007-11-14 13:04:23.000000000 +0100
+++ net-2.6.25/MAINTAINERS	2007-11-14 13:04:56.000000000 +0100
@@ -981,6 +981,15 @@
 L:	video4linux-list@redhat.com
 S:	Maintained
 
+CAN NETWORK LAYER
+P:	Urs Thuermann
+M:	urs.thuermann@volkswagen.de
+P:	Oliver Hartkopp
+M:	oliver.hartkopp@volkswagen.de
+L:	socketcan-core@lists.berlios.de
+W:	http://developer.berlios.de/projects/socketcan/
+S:	Maintained
+
 CALGARY x86-64 IOMMU
 P:	Muli Ben-Yehuda
 M:	muli@il.ibm.com

--
