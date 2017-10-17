From: <netanel@amazon.com>
Subject: [PATCH net-next 6/6] net: ena: increase ena driver version to 1.3.0
Date: Tue, 17 Oct 2017 07:34:01 +0000
Message-ID: <1508225641-106366-7-git-send-email-netanel@amazon.com>
References: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6002.amazon.com ([52.95.49.90]:48655 "EHLO
        smtp-fw-6002.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933732AbdJQHes (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:34:48 -0400
In-Reply-To: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index eafc5774dd49..ed8bd0a579c4 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -44,7 +44,7 @@
 #include "ena_eth_com.h"
 
 #define DRV_MODULE_VER_MAJOR	1
-#define DRV_MODULE_VER_MINOR	2
+#define DRV_MODULE_VER_MINOR	3
 #define DRV_MODULE_VER_SUBMINOR 0
 
 #define DRV_MODULE_NAME		"ena"
@@ -52,7 +52,7 @@
 #define DRV_MODULE_VERSION \
 	__stringify(DRV_MODULE_VER_MAJOR) "."	\
 	__stringify(DRV_MODULE_VER_MINOR) "."	\
-	__stringify(DRV_MODULE_VER_SUBMINOR) "k"
+	__stringify(DRV_MODULE_VER_SUBMINOR) "K"
 #endif
 
 #define DEVICE_NAME	"Elastic Network Adapter (ENA)"
-- 
1.8.3.1
