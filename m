From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [PATCH 2/3] hso maintainers update patch
Date: Mon, 08 Dec 2008 11:40:23 +0100
Message-ID: <493CF997.1080406@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010906020501070601000009"
To: Linux netdev Mailing list <netdev@vger.kernel.org>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:14547 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbYLHKk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 05:40:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010906020501070601000009
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Added D.J. Barrow as maintainer of hso driver.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: netdev-2.6/MAINTAINERS
===================================================================
--- netdev-2.6.orig/MAINTAINERS	2008-12-08 10:34:26.000000000 +0100
+++ netdev-2.6/MAINTAINERS	2008-12-08 11:29:47.000000000 +0100
@@ -2046,6 +2046,12 @@
 W:	http://artax.karlin.mff.cuni.cz/~mikulas/vyplody/hpfs/index-e.cgi
 S:	Maintained
 
+HSO	3G Modem Driver (hso.c)
+P:	Denis Joseph Barrow
+M:	d.barow@option.com
+W:	http://www.pharscape.org
+S:	Maintained
+
 HTCPEN TOUCHSCREEN DRIVER
 P:	Pau Oliva Fora
 M:	pof@eslack.org
Index: netdev-2.6/drivers/net/usb/hso.c
===================================================================
--- netdev-2.6.orig/drivers/net/usb/hso.c	2008-12-08 10:34:26.000000000 +0100
+++ netdev-2.6/drivers/net/usb/hso.c	2008-12-08 11:29:03.000000000 +0100
@@ -3,6 +3,8 @@
  * Driver for Option High Speed Mobile Devices.
  *
  *  Copyright (C) 2008 Option International
+ *                     Filip Aben <f.aben@option.com>
+ *                     Denis Joseph Barrow <d.barow@option.com>
  *  Copyright (C) 2007 Andrew Bird (Sphere Systems Ltd)
  *  			<ajb@spheresystems.co.uk>
  *  Copyright (C) 2008 Greg Kroah-Hartman <gregkh@suse.de>

-- 
best regards,
D.J. Barrow

--------------010906020501070601000009
Content-Type: text/x-diff;
 name="hso_maintainers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_maintainers.patch"

Added D.J. Barrow as maintainer of hso driver.
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: netdev-2.6/MAINTAINERS
===================================================================
--- netdev-2.6.orig/MAINTAINERS	2008-12-08 10:34:26.000000000 +0100
+++ netdev-2.6/MAINTAINERS	2008-12-08 11:29:47.000000000 +0100
@@ -2046,6 +2046,12 @@
 W:	http://artax.karlin.mff.cuni.cz/~mikulas/vyplody/hpfs/index-e.cgi
 S:	Maintained
 
+HSO	3G Modem Driver (hso.c)
+P:	Denis Joseph Barrow
+M:	d.barow@option.com
+W:	http://www.pharscape.org
+S:	Maintained
+
 HTCPEN TOUCHSCREEN DRIVER
 P:	Pau Oliva Fora
 M:	pof@eslack.org
Index: netdev-2.6/drivers/net/usb/hso.c
===================================================================
--- netdev-2.6.orig/drivers/net/usb/hso.c	2008-12-08 10:34:26.000000000 +0100
+++ netdev-2.6/drivers/net/usb/hso.c	2008-12-08 11:29:03.000000000 +0100
@@ -3,6 +3,8 @@
  * Driver for Option High Speed Mobile Devices.
  *
  *  Copyright (C) 2008 Option International
+ *                     Filip Aben <f.aben@option.com>
+ *                     Denis Joseph Barrow <d.barow@option.com>
  *  Copyright (C) 2007 Andrew Bird (Sphere Systems Ltd)
  *  			<ajb@spheresystems.co.uk>
  *  Copyright (C) 2008 Greg Kroah-Hartman <gregkh@suse.de>

--------------010906020501070601000009--
