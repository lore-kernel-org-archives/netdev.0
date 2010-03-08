From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH] MAINTAINERS: add netdev to CAN network layer and drivers
 entries
Date: Mon, 08 Mar 2010 21:46:55 +0100
Message-ID: <4B95623F.7010704@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:60796 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755577Ab0CHUsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:48:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 66418dd..c685ee2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1376,6 +1376,7 @@ M:	Oliver Hartkopp <socketcan@hartkopp.net>
 M:	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
 M:	Urs Thuermann <urs.thuermann@volkswagen.de>
 L:	socketcan-core@lists.berlios.de
+L:	netdev@vger.kernel.org
 W:	http://developer.berlios.de/projects/socketcan/
 S:	Maintained
 F:	net/can/
@@ -1387,6 +1388,7 @@ F:	include/linux/can/raw.h
 CAN NETWORK DRIVERS
 M:	Wolfgang Grandegger <wg@grandegger.com>
 L:	socketcan-core@lists.berlios.de
+L:	netdev@vger.kernel.org
 W:	http://developer.berlios.de/projects/socketcan/
 S:	Maintained
 F:	drivers/net/can/
