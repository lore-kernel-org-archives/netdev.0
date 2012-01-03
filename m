From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] fix CAN MAINTAINERS SCM tree type
Date: Tue, 03 Jan 2012 20:55:58 +0100
Message-ID: <4F035D4E.2070108@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Joe Perches <joe@perches.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As pointed out by Joe Perches the SCM tree type was missing in my patch.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

CC: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
CC: Urs Thuermann <urs.thuermann@volkswagen.de>
CC: Wolfgang Grandegger <wg@grandegger.com>
CC: Marc Kleine-Budde <mkl@pengutronix.de>
CC: linux-can@vger.kernel.org

---

diff -u -r a/MAINTAINERS b/MAINTAINERS
--- a/MAINTAINERS	2012-01-03 20:48:07.160746574 +0100
+++ b/MAINTAINERS	2012-01-03 20:48:51.208745047 +0100
@@ -1700,7 +1700,7 @@
 M:	Oliver Hartkopp <socketcan@hartkopp.net>
 L:	linux-can@vger.kernel.org
 W:	http://gitorious.org/linux-can
-T:	git://gitorious.org/linux-can/linux-can-next.git
+T:	git git://gitorious.org/linux-can/linux-can-next.git
 S:	Maintained
 F:	net/can/
 F:	include/linux/can.h
@@ -1714,7 +1714,7 @@
 M:	Marc Kleine-Budde <mkl@pengutronix.de>
 L:	linux-can@vger.kernel.org
 W:	http://gitorious.org/linux-can
-T:	git://gitorious.org/linux-can/linux-can-next.git
+T:	git git://gitorious.org/linux-can/linux-can-next.git
 S:	Maintained
 F:	drivers/net/can/
 F:	include/linux/can/dev.h


