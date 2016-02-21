From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/5] qed,qede: Bump driver versions to 8.7.0.0
Date: Sun, 21 Feb 2016 11:40:11 +0200
Message-ID: <1456047611-11222-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62251 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750973AbcBURpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:45:46 -0500
In-Reply-To: <1456047611-11222-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h   | 2 +-
 drivers/net/ethernet/qlogic/qede/qede.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index d34da63..66b021e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -26,7 +26,7 @@
 #include "qed_hsi.h"
 
 extern const struct qed_common_ops qed_common_ops_pass;
-#define DRV_MODULE_VERSION "8.4.0.0"
+#define DRV_MODULE_VERSION "8.7.0.0"
 
 #define MAX_HWFNS_PER_DEVICE    (4)
 #define NAME_SIZE 16
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 15c5528..02e17d3 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -24,7 +24,7 @@
 #include <linux/qed/qed_eth_if.h>
 
 #define QEDE_MAJOR_VERSION		8
-#define QEDE_MINOR_VERSION		4
+#define QEDE_MINOR_VERSION		7
 #define QEDE_REVISION_VERSION		0
 #define QEDE_ENGINEERING_VERSION	0
 #define DRV_MODULE_VERSION __stringify(QEDE_MAJOR_VERSION) "."	\
-- 
1.9.3
