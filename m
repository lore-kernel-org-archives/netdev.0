From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: update latest firmware version supported
Date: Tue, 31 Jan 2017 13:21:50 +0530
Message-ID: <1485849110-5650-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:8637 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdAaHxM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:53:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change t4fw_version.h to update latest firmware version
number 1.16.26.0.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
index 2accab3..5fdaa16 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -36,8 +36,8 @@
 #define __T4FW_VERSION_H__
 
 #define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x0F
-#define T4FW_VERSION_MICRO 0x25
+#define T4FW_VERSION_MINOR 0x10
+#define T4FW_VERSION_MICRO 0x1A
 #define T4FW_VERSION_BUILD 0x00
 
 #define T4FW_MIN_VERSION_MAJOR 0x01
@@ -45,8 +45,8 @@
 #define T4FW_MIN_VERSION_MICRO 0x00
 
 #define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x0F
-#define T5FW_VERSION_MICRO 0x25
+#define T5FW_VERSION_MINOR 0x10
+#define T5FW_VERSION_MICRO 0x1A
 #define T5FW_VERSION_BUILD 0x00
 
 #define T5FW_MIN_VERSION_MAJOR 0x00
@@ -54,8 +54,8 @@
 #define T5FW_MIN_VERSION_MICRO 0x00
 
 #define T6FW_VERSION_MAJOR 0x01
-#define T6FW_VERSION_MINOR 0x0F
-#define T6FW_VERSION_MICRO 0x25
+#define T6FW_VERSION_MINOR 0x10
+#define T6FW_VERSION_MICRO 0x1A
 #define T6FW_VERSION_BUILD 0x00
 
 #define T6FW_MIN_VERSION_MAJOR 0x00
-- 
2.1.0
