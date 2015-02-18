From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: [net-next 3/3] bnx2-cnic: Driver Version Update
Date: Tue, 17 Feb 2015 19:26:20 -0500
Message-ID: <1424219180-29028-4-git-send-email-rasesh.mody@qlogic.com>
References: <1424219180-29028-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46976 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbbBRBF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 20:05:59 -0500
In-Reply-To: <1424219180-29028-1-git-send-email-rasesh.mody@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates BNX2 driver version to 2.2.6 and CNIC driver version
to 2.5.21.

Signed-off-by: Rasesh Mody <rasesh.mody@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2.c    | 4 ++--
 drivers/net/ethernet/broadcom/cnic_if.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 4b48e21..dcd4bcc 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -58,8 +58,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.2.5"
-#define DRV_MODULE_RELDATE	"December 20, 2013"
+#define DRV_MODULE_VERSION	"2.2.6"
+#define DRV_MODULE_RELDATE	"January 29, 2014"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.3.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1b.fw"
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 7fe0b64..ef6125b 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -15,8 +15,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.20"
-#define CNIC_MODULE_RELDATE	"March 14, 2014"
+#define CNIC_MODULE_VERSION	"2.5.21"
+#define CNIC_MODULE_RELDATE	"January 29, 2015"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.8.2.3
