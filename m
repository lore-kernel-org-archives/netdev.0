From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [PATCH 6/7] CAN: Add maintainer entries
Date: Tue,  2 Oct 2007 15:10:12 +0200
Message-ID: <20071002131113.31727.6@janus.isnogud.escape.de>
References: <20071002131006.31727.0@janus.isnogud.escape.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:60142 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755288AbXJBNVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 09:21:08 -0400
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

Index: net-2.6.24/CREDITS
===================================================================
--- net-2.6.24.orig/CREDITS	2007-09-20 06:37:28.000000000 +0200
+++ net-2.6.24/CREDITS	2007-10-02 12:03:43.000000000 +0200
@@ -1347,6 +1347,14 @@
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
@@ -3300,6 +3308,14 @@
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
Index: net-2.6.24/MAINTAINERS
===================================================================
--- net-2.6.24.orig/MAINTAINERS	2007-09-28 18:01:52.000000000 +0200
+++ net-2.6.24/MAINTAINERS	2007-10-02 12:03:43.000000000 +0200
@@ -991,6 +991,15 @@
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
