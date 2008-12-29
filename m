From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: net: KS8695: removed duplicated #include
Date: Tue, 30 Dec 2008 06:48:23 +0800
Message-ID: <20081230064550.4609.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:6252 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbYL2Ws0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 17:48:26 -0500
Received: by ti-out-0910.google.com with SMTP id b6so7864434tic.23
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2008 14:48:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated include in drivers/net/arm/ks8695net.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 592daee..9ad22d1 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -29,7 +29,6 @@
 #include <linux/delay.h>
 #include <linux/platform_device.h>
 #include <linux/irq.h>
-#include <linux/delay.h>
 #include <linux/io.h>

 #include <asm/irq.h>


