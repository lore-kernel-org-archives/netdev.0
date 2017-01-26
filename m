From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V3 net-next 14/14] net/ena: update driver version to 1.1.2
Date: Fri, 27 Jan 2017 00:18:16 +0200
Message-ID: <1485469096-5271-15-git-send-email-netanel@annapurnalabs.com>
References: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36194 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754317AbdAZWTE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:19:04 -0500
Received: by mail-wm0-f50.google.com with SMTP id c85so92153578wmi.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 14:18:59 -0800 (PST)
In-Reply-To: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index efe0ea1..ed62d8e 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -44,7 +44,7 @@
 #include "ena_eth_com.h"
 
 #define DRV_MODULE_VER_MAJOR	1
-#define DRV_MODULE_VER_MINOR	0
+#define DRV_MODULE_VER_MINOR	1
 #define DRV_MODULE_VER_SUBMINOR 2
 
 #define DRV_MODULE_NAME		"ena"
-- 
2.7.4
