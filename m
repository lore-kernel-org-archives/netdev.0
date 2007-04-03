From: Ramkrishna Vepa <ramkrishna.vepa@neterion.com>
Subject: [PATCH]S2io: Change of driver maintainers
Date: Tue, 03 Apr 2007 13:18:19 -0700
Message-ID: <1175631499.4681.5.camel@mandrake>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jeff@garzik.org, alicia.pena@neterion.com,
	ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:3303 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422693AbXDCUSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 16:18:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Changed the maintainers for the S2io driver.
(Resending; forgot to send to netdev)

Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -pNur linux-2.6.org/drivers/net/s2io.c linux-2.6/drivers/net/s2io.c
--- linux-2.6.org/drivers/net/s2io.c	2007-03-29 18:49:39.000000000 -0700
+++ linux-2.6/drivers/net/s2io.c	2007-03-29 19:06:52.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.19.1"
+#define DRV_VERSION "2.0.22.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -394,7 +394,6 @@ static const u64 fix_mac[] = {
 	END_SIGN
 };
 
-MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@neterion.com>");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
diff -pNur linux-2.6.org/MAINTAINERS linux-2.6/MAINTAINERS
--- linux-2.6.org/MAINTAINERS	2007-03-29 18:49:39.000000000 -0700
+++ linux-2.6/MAINTAINERS	2007-03-29 19:00:46.000000000 -0700
@@ -2470,6 +2470,19 @@ M:	adaplas@gmail.com
 L:	linux-fbdev-devel@lists.sourceforge.net (subscribers-only)
 S:	Maintained
 
+NETERION (S2IO) Xframe 10GbE DRIVER
+P:	Ramkrishna Vepa
+M:	ram.vepa@neterion.com
+P:	Rastapur Santosh
+M:	santosh.rastapur@neterion.com
+P:	Sivakumar Subramani
+M:	sivakumar.subramani@neterion.com
+P:	Sreenivasa Honnur
+M:	sreenivasa.honnur@neterion.com
+L:	netdev@vger.kernel.org
+W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/TitleIndex?anonymous
+S:	Supported
+
 OPENCORES I2C BUS DRIVER
 P:	Peter Korsgaard
 M:	jacmet@sunsite.dk

