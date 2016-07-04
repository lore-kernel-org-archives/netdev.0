From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 9/9] net: r6040: Bump version and date
Date: Mon,  4 Jul 2016 14:36:09 -0700
Message-ID: <1467668169-31547-10-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34087 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932599AbcGDVgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:22 -0400
Received: by mail-oi0-f67.google.com with SMTP id s17so24991655oih.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:22 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump version to 0.28 and date to 4th of July 2016.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index c8985cfbe2da..cb29ee24cf1b 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -48,8 +48,8 @@
 #include <asm/processor.h>
 
 #define DRV_NAME	"r6040"
-#define DRV_VERSION	"0.28"
-#define DRV_RELDATE	"07Oct2011"
+#define DRV_VERSION	"0.29"
+#define DRV_RELDATE	"04Jul2016"
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT	(6000 * HZ / 1000)
-- 
2.7.4
