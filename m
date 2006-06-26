From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: update info page for a bunch of my drivers
Date: Mon, 26 Jun 2006 21:36:52 +0200
Message-ID: <m3odwflne3.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:33501 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S932960AbWFZTgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 15:36:54 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updates generic HDLC info page address, I should have done it
long time ago.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -7,7 +7,7 @@
  * under the terms of version 2 of the GNU General Public License
  * as published by the Free Software Foundation.
  *
- * For information see http://hq.pm.waw.pl/hdlc/
+ * For information see <http://www.kernel.org/pub/linux/utils/net/hdlc/>
  *
  * Sources of information:
  *    Hitachi HD64570 SCA User's Manual
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -7,7 +7,7 @@
  * under the terms of version 2 of the GNU General Public License
  * as published by the Free Software Foundation.
  *
- * For information see http://hq.pm.waw.pl/hdlc/
+ * For information see <http://www.kernel.org/pub/linux/utils/net/hdlc/>
  *
  * Note: integrated CSU/DSU/DDS are not supported by this driver
  *
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -7,7 +7,7 @@
  * under the terms of version 2 of the GNU General Public License
  * as published by the Free Software Foundation.
  *
- * For information see http://hq.pm.waw.pl/hdlc/
+ * For information see <http://www.kernel.org/pub/linux/utils/net/hdlc/>
  *
  * Sources of information:
  *    Hitachi HD64572 SCA-II User's Manual
