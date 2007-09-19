From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/1] From: Ursula Braun <braunu@de.ibm.com>
Date: Wed, 19 Sep 2007 13:09:02 +0200
Message-ID: <20070919111027.298899000@linux.vnet.ibm.com>
References: <20070919110901.080242000@linux.vnet.ibm.com>
To: davem@davemloft.net, jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:61166 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985AbXISLKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 07:10:33 -0400
Content-Disposition: inline; filename=s390-MAINTAINERS.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] s390 MAINTAINERS

maintainer change for s390 networking

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 MAINTAINERS |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

===================================================================
Index: net-2.6-uschi/MAINTAINERS
===================================================================
--- net-2.6-uschi.orig/MAINTAINERS
+++ net-2.6-uschi/MAINTAINERS
@@ -3056,8 +3056,8 @@ W:	http://www.ibm.com/developerworks/lin
 S:	Supported
 
 S390 NETWORK DRIVERS
-P:	Frank Pavlic
-M:	fpavlic@de.ibm.com
+P:	Ursula Braun
+M:	ubraun@linux.vnet.ibm.com
 M:	linux390@de.ibm.com
 L:	linux-s390@vger.kernel.org
 W:	http://www.ibm.com/developerworks/linux/linux390/
@@ -3071,6 +3071,14 @@ L:	linux-s390@vger.kernel.org
 W:	http://www.ibm.com/developerworks/linux/linux390/
 S:	Supported
 
+S390 IUCV NETWORK LAYER
+P:	Ursula Braun
+M:	ubraun@linux.vnet.ibm.com
+M:	linux390@de.ibm.com
+L:	linux-s390@vger.kernel.org
+W:	http://www.ibm.com/developerworks/linux/linux390/
+S:	Supported
+
 SAA7146 VIDEO4LINUX-2 DRIVER
 P:	Michael Hunold
 M:	michael@mihu.de

-- 
