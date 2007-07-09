From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 06/12] sky2: unmark as EXPERIMENTAL
Date: Mon, 09 Jul 2007 15:33:38 -0700
Message-ID: <20070709223453.346228899@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51975 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755928AbXGIWh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:37:26 -0400
Content-Disposition: inline; filename=sky2-not-exp.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/Kconfig	2007-07-09 15:30:09.000000000 -0700
+++ b/drivers/net/Kconfig	2007-07-09 15:30:11.000000000 -0700
@@ -2118,7 +2118,7 @@ config SKGE
 	  will be called skge.  This is recommended.
 
 config SKY2
-	tristate "SysKonnect Yukon2 support (EXPERIMENTAL)"
+	tristate "SysKonnect Yukon2 support"
 	depends on PCI
 	select CRC32
 	---help---

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

