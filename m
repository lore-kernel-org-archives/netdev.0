From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/6] MAINTAINERS: add Marc Kleine-Budde as co maintinaer for CAN networking layer
Date: Mon,  9 Mar 2015 10:36:21 +0100
Message-ID: <1425893781-10867-7-git-send-email-mkl@pengutronix.de>
References: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50354 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbbCIJgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:36:51 -0400
In-Reply-To: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds Marc Kleine-Budde as a co maintinaer for CAN networking layer.

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ce4380d7ab1a..ba57e5d3ed5c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2369,6 +2369,7 @@ F:	arch/x86/include/asm/tce.h
 
 CAN NETWORK LAYER
 M:	Oliver Hartkopp <socketcan@hartkopp.net>
+M:	Marc Kleine-Budde <mkl@pengutronix.de>
 L:	linux-can@vger.kernel.org
 W:	https://github.com/linux-can
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git
-- 
2.1.4
