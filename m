From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/8] MAINTAINERS: update linux-can git repositories
Date: Thu, 15 Jan 2015 17:11:16 +0100
Message-ID: <1421338283-12417-2-git-send-email-mkl@pengutronix.de>
References: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56593 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbAOQLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 11:11:31 -0500
In-Reply-To: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The linux-can upstream git repositories are now hosted on kernel.org, update
MAINTAINERS accordingly.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 MAINTAINERS | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 600d2aad8276..efa5f8d4086d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2346,7 +2346,8 @@ CAN NETWORK LAYER
 M:	Oliver Hartkopp <socketcan@hartkopp.net>
 L:	linux-can@vger.kernel.org
 W:	http://gitorious.org/linux-can
-T:	git git://gitorious.org/linux-can/linux-can-next.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git
 S:	Maintained
 F:	Documentation/networking/can.txt
 F:	net/can/
@@ -2361,7 +2362,8 @@ M:	Wolfgang Grandegger <wg@grandegger.com>
 M:	Marc Kleine-Budde <mkl@pengutronix.de>
 L:	linux-can@vger.kernel.org
 W:	http://gitorious.org/linux-can
-T:	git git://gitorious.org/linux-can/linux-can-next.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git
 S:	Maintained
 F:	drivers/net/can/
 F:	include/linux/can/dev.h
-- 
2.1.4
