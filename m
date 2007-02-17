From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH] Correct links in net/ipv4/Kconfig
Date: Sat, 17 Feb 2007 15:57:38 +0200
Message-ID: <20070217135738.GE25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:42968
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946745AbXBQN5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Feb 2007 08:57:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix bug #6216, update the link for CONFIG_IP_MCAST help message. The bug with
the proposed fix was submitted by jamesm@bluebottle.com

Correct other dead/indirect links in the same file.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6-gt/net/ipv4/Kconfig
===================================================================
--- 2.6-gt.orig/net/ipv4/Kconfig	2007-02-17 15:47:41.000000000 +0200
+++ 2.6-gt/net/ipv4/Kconfig	2007-02-17 15:55:53.000000000 +0200
@@ -9,7 +9,7 @@
 	  intend to participate in the MBONE, a high bandwidth network on top
 	  of the Internet which carries audio and video broadcasts. More
 	  information about the MBONE is on the WWW at
-	  <http://www-itg.lbl.gov/mbone/>. Information about the multicast
+	  <http://www.savetz.com/mbone/>. Information about the multicast
 	  capabilities of the various network cards is contained in
 	  <file:Documentation/networking/multicast.txt>. For most people, it's
 	  safe to say N.
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
