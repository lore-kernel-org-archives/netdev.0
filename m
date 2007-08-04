From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [patch 6/7] CAN: Add maintainer entries
Date: Sat,  4 Aug 2007 04:07:03 +0200
Message-ID: <20070804020757.25572.6@janus.isnogud.escape.de>
References: <20070804020657.25572.0@janus.isnogud.escape.de>
Cc: urs@isnogud.escape.de, oliver@hartkopp.net, davem@davemloft.net,
	kaber@trash.net, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:50264 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760187AbXHDCUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 22:20:33 -0400
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

Index: net-2.6/CREDITS
===================================================================
--- net-2.6.orig/CREDITS	2007-08-03 11:21:31.000000000 +0200
+++ net-2.6/CREDITS	2007-08-03 11:21:56.000000000 +0200
@@ -1331,6 +1331,14 @@
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
@@ -3284,6 +3292,14 @@
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
Index: net-2.6/MAINTAINERS
===================================================================
--- net-2.6.orig/MAINTAINERS	2007-08-03 11:21:31.000000000 +0200
+++ net-2.6/MAINTAINERS	2007-08-03 11:21:56.000000000 +0200
@@ -951,6 +951,15 @@
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
