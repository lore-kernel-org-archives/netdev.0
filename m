From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 4/4] bna: Driver and Firmware Updated
Date: Fri, 10 May 2013 10:02:17 -0700
Message-ID: <1368205337-4624-5-git-send-email-rmody@brocade.com>
References: <1368205337-4624-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:50690 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753985Ab3EJRS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 13:18:59 -0400
In-Reply-To: <1368205337-4624-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

        Driver and Firmware versions updated to 3.2.21.1.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.h |    2 +-
 drivers/net/ethernet/brocade/bna/cna.h  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index c1d0bc0..aefee77 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -71,7 +71,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"3.1.2.1"
+#define BNAD_VERSION			"3.2.21.1"
 
 #define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index 14ca931..c37f706 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -37,8 +37,8 @@
 
 extern char bfa_version[];
 
-#define CNA_FW_FILE_CT	"ctfw-3.1.0.0.bin"
-#define CNA_FW_FILE_CT2	"ct2fw-3.1.0.0.bin"
+#define CNA_FW_FILE_CT	"ctfw-3.2.1.0.bin"
+#define CNA_FW_FILE_CT2	"ct2fw-3.2.1.0.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
 #pragma pack(1)
-- 
1.7.1
