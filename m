From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: remove extra help text from HDLC_PPP config option
Date: Mon, 30 Jun 2008 22:09:15 +0200
Message-ID: <m3vdzq4rdg.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45265 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751492AbYF3UJS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 16:09:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove extra help text from HDLC_PPP config option.

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index d3c2773..8f3ac39 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -154,8 +154,6 @@ config HDLC_PPP
 	help
 	  Generic HDLC driver supporting PPP over WAN connections.
=20
-	  It will be replaced by new PPP implementation in Linux 2.6.26.
-
 	  If unsure, say N.
=20
 config HDLC_X25
