From: <netanel@amazon.com>
Subject: [PATCH net 9/9] net: ena: update ena driver to version 1.1.7
Date: Sun, 11 Jun 2017 15:42:51 +0300
Message-ID: <1497184971-28178-10-git-send-email-netanel@amazon.com>
References: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:6266 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdFKMyT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 08:54:19 -0400
In-Reply-To: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 88b5e5612338..a4d3d5e21068 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -45,7 +45,7 @@
 
 #define DRV_MODULE_VER_MAJOR	1
 #define DRV_MODULE_VER_MINOR	1
-#define DRV_MODULE_VER_SUBMINOR 2
+#define DRV_MODULE_VER_SUBMINOR 7
 
 #define DRV_MODULE_NAME		"ena"
 #ifndef DRV_MODULE_VERSION
-- 
2.7.4
