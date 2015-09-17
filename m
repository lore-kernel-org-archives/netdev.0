From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH][RESEND] MAINTAINERS: add arcnet and take maintainership
Date: Thu, 17 Sep 2015 15:26:16 +0200
Message-ID: <1442496376-14612-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: davem@davemloft.net, joe@perches.com, kernel@pengutronix.de
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33911 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbbIQN01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 09:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add entry for arcnet to MAINTAINERS file and add myself as the
maintainer of the subsystem.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
Cc: davem@davemloft.net
Cc: joe@perches.com
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7ba7ab7..0a015f7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -808,6 +808,13 @@ S:	Maintained
 F:	drivers/video/fbdev/arcfb.c
 F:	drivers/video/fbdev/core/fb_defio.c
 
+ARCNET NETWORK LAYER
+M:	Michael Grzeschik <m.grzeschik@pengutronix.de>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/arcnet/
+F:	include/uapi/linux/if_arcnet.h
+
 ARM MFM AND FLOPPY DRIVERS
 M:	Ian Molton <spyro@f2s.com>
 S:	Maintained
-- 
2.5.1
