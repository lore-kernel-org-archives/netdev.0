From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: update the firmware download URL in Kconfig
Date: Tue, 05 Sep 2006 21:58:50 -0400
Message-ID: <44FE2B5A.7020506@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:2466 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S965222AbWIFB7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 21:59:23 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Could you please push the following patch to Linus before 2.6.18?
It updates the firmware download URL in Kconfig to match the header
in drivers/net/myri10ge/myri10ge.c.

Thanks!
Brice Goglin



From: Brice Goglin <brice@myri.com>

[PATCH] myri10ge: update the firmware download URL in Kconfig

Update the firmware download URL in Kconfig to match the header
in drivers/net/myri10ge/myri10ge.c.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-rc/drivers/net/Kconfig
===================================================================
--- linux-rc.orig/drivers/net/Kconfig	2006-09-05 11:19:37.000000000 -0400
+++ linux-rc/drivers/net/Kconfig	2006-09-05 11:19:49.000000000 -0400
@@ -2393,7 +2393,7 @@
 	  you will need a newer firmware image.
 	  You may get this image or more information, at:
 
-	  <http://www.myri.com/Myri-10G/>
+	  <http://www.myri.com/scs/download-Myri10GE.html>
 
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>.  The module


