From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH] Correct links in net/ipv4/Kconfig
Date: Wed, 21 Feb 2007 20:23:35 +0200
Message-ID: <20070221182335.GR25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:22054
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422764AbXBUSXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 13:23:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct dead/indirect links in net/ipv4/Kconfig

Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6-gt/net/ipv4/Kconfig
===================================================================
--- 2.6-gt.orig/net/ipv4/Kconfig	2007-02-17 15:47:41.000000000 +0200
+++ 2.6-gt/net/ipv4/Kconfig	2007-02-17 15:55:53.000000000 +0200
@@ -442,7 +442,7 @@
 	---help---
 	  Support for INET (TCP, DCCP, etc) socket monitoring interface used by
 	  native Linux tools such as ss. ss is included in iproute2, currently
-	  downloadable at <http://developer.osdl.org/dev/iproute2>. 
+	  downloadable at <http://linux-net.osdl.org/index.php/Iproute2>.
 	  
 	  If unsure, say Y.
 
@@ -550,7 +550,7 @@
 	Scalable TCP is a sender-side only change to TCP which uses a
 	MIMD congestion control algorithm which has some nice scaling
 	properties, though is known to have fairness issues.
-	See http://www-lce.eng.cam.ac.uk/~ctk21/scalable/
+	See http://www.deneholme.net/tom/scalable/
 
 config TCP_CONG_LP
 	tristate "TCP Low Priority"
