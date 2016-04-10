From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH 4/4] qed* - bump driver versions to 8.7.1.20
Date: Sun, 10 Apr 2016 12:43:02 +0300
Message-ID: <1460281382-13656-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37928 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752485AbcDJJnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 05:43:16 -0400
In-Reply-To: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h   | 2 +-
 drivers/net/ethernet/qlogic/qede/qede.h | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index a3ee9df..0f0d2d1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -26,7 +26,7 @@
 #include "qed_hsi.h"
 
 extern const struct qed_common_ops qed_common_ops_pass;
-#define DRV_MODULE_VERSION "8.7.0.0"
+#define DRV_MODULE_VERSION "8.7.1.20"
 
 #define MAX_HWFNS_PER_DEVICE    (4)
 #define NAME_SIZE 16
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 80dbb73..41c4189 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -25,8 +25,8 @@
 
 #define QEDE_MAJOR_VERSION		8
 #define QEDE_MINOR_VERSION		7
-#define QEDE_REVISION_VERSION		0
-#define QEDE_ENGINEERING_VERSION	0
+#define QEDE_REVISION_VERSION		1
+#define QEDE_ENGINEERING_VERSION	20
 #define DRV_MODULE_VERSION __stringify(QEDE_MAJOR_VERSION) "."	\
 		__stringify(QEDE_MINOR_VERSION) "."		\
 		__stringify(QEDE_REVISION_VERSION) "."		\
-- 
1.9.3
