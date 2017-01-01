From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 12/12] qed*: Advance driver versions to 8.10.10.20.
Date: Sun, 1 Jan 2017 13:57:11 +0200
Message-ID: <1483271831-25890-13-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53894 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932224AbdAAL6j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:39 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h   | 2 +-
 drivers/net/ethernet/qlogic/qede/qede.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index f6e0ff4..1f61cf3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -51,7 +51,7 @@
 #include "qed_hsi.h"
 
 extern const struct qed_common_ops qed_common_ops_pass;
-#define DRV_MODULE_VERSION "8.10.9.20"
+#define DRV_MODULE_VERSION "8.10.10.20"
 
 #define MAX_HWFNS_PER_DEVICE    (4)
 #define NAME_SIZE 16
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index f4e9423..b423406 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -49,7 +49,7 @@
 
 #define QEDE_MAJOR_VERSION		8
 #define QEDE_MINOR_VERSION		10
-#define QEDE_REVISION_VERSION		9
+#define QEDE_REVISION_VERSION		10
 #define QEDE_ENGINEERING_VERSION	20
 #define DRV_MODULE_VERSION __stringify(QEDE_MAJOR_VERSION) "."	\
 		__stringify(QEDE_MINOR_VERSION) "."		\
-- 
1.9.3
