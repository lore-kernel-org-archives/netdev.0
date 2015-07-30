From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH] MAINTAINERS: add arcnet and take maintainership
Date: Thu, 30 Jul 2015 15:30:13 +0200
Message-ID: <1438263013-13262-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: davem@davemloft.net, joe@perches.com, kernel@pengutronix.de
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add entry for arcnet to MAINTAINERS file and add myself as the
maintainer of the subsystem.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
Cc: davem@davemloft.net
Cc: joe@perches.com
---
As I have a test coverage of com20020 based arcnet systems
I would like to take the responsibility of maintaining the subsystem.

 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9289ecb..08f1a41 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -790,6 +790,12 @@ S:	Maintained
 F:	drivers/video/fbdev/arcfb.c
 F:	drivers/video/fbdev/core/fb_defio.c
 
+ARCNET NETWORK LAYER
+M:	Michael Grzeschik <m.grzeschik@pengutronix.de>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/arcnet/
+
 ARM MFM AND FLOPPY DRIVERS
 M:	Ian Molton <spyro@f2s.com>
 S:	Maintained
-- 
2.1.4
