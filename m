From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH] cxgb4: update latest firmware version supported
Date: Tue, 5 Jul 2016 18:07:24 +0530
Message-ID: <1467722244-8644-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <hariprasad@chelsio.com>,
	<nirranjan@chelsio.com>, Ganesh Goudar <ganeshgr@chelsio.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:4989 "EHLO stargate.chelsio.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754484AbcGEMhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 08:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change t4fw_version.h to update latest firmware version number

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
index c4b262c..2accab3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -36,8 +36,8 @@
 #define __T4FW_VERSION_H__
 
 #define T4FW_VERSION_MAJOR 0x01
-#define T4FW_VERSION_MINOR 0x0E
-#define T4FW_VERSION_MICRO 0x04
+#define T4FW_VERSION_MINOR 0x0F
+#define T4FW_VERSION_MICRO 0x25
 #define T4FW_VERSION_BUILD 0x00
 
 #define T4FW_MIN_VERSION_MAJOR 0x01
@@ -45,8 +45,8 @@
 #define T4FW_MIN_VERSION_MICRO 0x00
 
 #define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x0E
-#define T5FW_VERSION_MICRO 0x04
+#define T5FW_VERSION_MINOR 0x0F
+#define T5FW_VERSION_MICRO 0x25
 #define T5FW_VERSION_BUILD 0x00
 
 #define T5FW_MIN_VERSION_MAJOR 0x00
@@ -54,8 +54,8 @@
 #define T5FW_MIN_VERSION_MICRO 0x00
 
 #define T6FW_VERSION_MAJOR 0x01
-#define T6FW_VERSION_MINOR 0x0E
-#define T6FW_VERSION_MICRO 0x04
+#define T6FW_VERSION_MINOR 0x0F
+#define T6FW_VERSION_MICRO 0x25
 #define T6FW_VERSION_BUILD 0x00
 
 #define T6FW_MIN_VERSION_MAJOR 0x00
-- 
2.1.0
