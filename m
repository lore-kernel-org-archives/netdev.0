From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [patch 6/7] CAN: Add maintainer entries - update for offset in current
 net-2.6.23.git
Date: Wed, 27 Jun 2007 05:29:37 +0200
Message-ID: <4681D9A1.8060206@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:44113 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbXF0D3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 23:29:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds entries in the CREDITS and MAINTAINERS file for CAN.

Signed-Off-By: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Signed-Off-By: Urs Thuermann <urs.thuermann@volkswagen.de>

---
 CREDITS     |   16 ++++++++++++++++
 MAINTAINERS |    9 +++++++++
 2 files changed, 25 insertions(+)

Index: linux-2.6.22-rc5/CREDITS
===================================================================
--- linux-2.6.22-rc5.orig/CREDITS	2007-06-20 14:10:41.000000000 +0200
+++ linux-2.6.22-rc5/CREDITS	2007-06-20 14:11:27.000000000 +0200
@@ -1330,6 +1330,14 @@
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
@@ -3283,6 +3291,14 @@
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
Index: linux-2.6.22-rc5/MAINTAINERS
===================================================================
--- linux-2.6.22-rc5.orig/MAINTAINERS	2007-06-20 14:10:41.000000000 +0200
+++ linux-2.6.22-rc5/MAINTAINERS	2007-06-20 14:11:27.000000000 +0200
@@ -941,6 +941,15 @@
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





