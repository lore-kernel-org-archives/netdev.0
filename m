From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 5/5] qlcnic: Update version to 5.3.59
Date: Wed, 7 May 2014 13:39:38 -0400
Message-ID: <1399484378-22864-6-git-send-email-rajesh.borundia@qlogic.com>
References: <1399484378-22864-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:39280 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751298AbaEGSIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 14:08:31 -0400
In-Reply-To: <1399484378-22864-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 557b911..6cb24dc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -39,8 +39,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 3
-#define _QLCNIC_LINUX_SUBVERSION 58
-#define QLCNIC_LINUX_VERSIONID  "5.3.58"
+#define _QLCNIC_LINUX_SUBVERSION 59
+#define QLCNIC_LINUX_VERSIONID  "5.3.59"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.6.3.3
