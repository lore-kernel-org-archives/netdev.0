From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [patch 6/7] CAN: Add maintainer entries
Date: Wed, 16 May 2007 16:51:06 +0200
Message-ID: <20070516145123.29877.6@janus.isnogud.escape.de>
References: <20070516145100.29877.0@janus.isnogud.escape.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:58939 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756659AbXEPPUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:20:14 -0400
Content-Disposition: inline; filename=06-can-maintainers.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds entries in the CREDITS and MAINTAINERS file for CAN.

Signed-Off-By: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Signed-Off-By: Urs Thuermann <urs.thuermann@volkswagen.de>

---
 CREDITS     |   16 ++++++++++++++++
 MAINTAINERS |    9 +++++++++
 2 files changed, 25 insertions(+)

Index: linux-2.6.22-rc1-git4/CREDITS
===================================================================
--- linux-2.6.22-rc1-git4.orig/CREDITS	2007-05-16 09:33:39.000000000 +0200
+++ linux-2.6.22-rc1-git4/CREDITS	2007-05-16 09:34:51.000000000 +0200
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
Index: linux-2.6.22-rc1-git4/MAINTAINERS
===================================================================
--- linux-2.6.22-rc1-git4.orig/MAINTAINERS	2007-05-16 09:34:02.000000000 +0200
+++ linux-2.6.22-rc1-git4/MAINTAINERS	2007-05-16 09:34:51.000000000 +0200
@@ -931,6 +931,15 @@
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
