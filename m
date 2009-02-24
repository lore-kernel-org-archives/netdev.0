From: Joe Perches <joe@perches.com>
Subject: [PATCH] tcp_scalable: Update malformed & dead url
Date: Tue, 24 Feb 2009 09:18:24 -0800
Message-ID: <1235495904.2501.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Kelly <tom.kelly@cantab.net>,
	John Heffner <johnwheffner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4909 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1757053AbZBXRQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 12:16:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index 2747ec7..4660b08 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -1,6 +1,6 @@
 /* Tom Kelly's Scalable TCP
  *
- * See htt://www-lce.eng.cam.ac.uk/~ctk21/scalable/
+ * See http://www.deneholme.net/tom/scalable/
  *
  * John Heffner <jheffner@sc.edu>
  */


