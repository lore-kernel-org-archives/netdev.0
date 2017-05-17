From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net] cxgb4: update latest firmware version supported
Date: Thu, 18 May 2017 00:08:16 +0530
Message-ID: <1495046296-9009-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:18750 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdEQSjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 14:39:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change t4fw_version.h to update latest firmware version
number to 1.16.43.0.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
index fa37644..3549d387 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -37,7 +37,7 @@
 
 #define T4FW_VERSION_MAJOR 0x01
 #define T4FW_VERSION_MINOR 0x10
-#define T4FW_VERSION_MICRO 0x21
+#define T4FW_VERSION_MICRO 0x2B
 #define T4FW_VERSION_BUILD 0x00
 
 #define T4FW_MIN_VERSION_MAJOR 0x01
@@ -46,7 +46,7 @@
 
 #define T5FW_VERSION_MAJOR 0x01
 #define T5FW_VERSION_MINOR 0x10
-#define T5FW_VERSION_MICRO 0x21
+#define T5FW_VERSION_MICRO 0x2B
 #define T5FW_VERSION_BUILD 0x00
 
 #define T5FW_MIN_VERSION_MAJOR 0x00
@@ -55,7 +55,7 @@
 
 #define T6FW_VERSION_MAJOR 0x01
 #define T6FW_VERSION_MINOR 0x10
-#define T6FW_VERSION_MICRO 0x21
+#define T6FW_VERSION_MICRO 0x2B
 #define T6FW_VERSION_BUILD 0x00
 
 #define T6FW_MIN_VERSION_MAJOR 0x00
-- 
2.1.0
