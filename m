From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next 2/2] qlcnic: Update version to 5.3.61
Date: Fri, 27 Jun 2014 19:01:39 -0400
Message-ID: <1403910099-2835-3-git-send-email-harish.patil@qlogic.com>
References: <1403910099-2835-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:61522 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751273AbaF0XcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:32:23 -0400
In-Reply-To: <1403910099-2835-1-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

Signed-off-by: Harish Patil <harish.patil@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index be618b9..16039d1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -39,8 +39,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 3
-#define _QLCNIC_LINUX_SUBVERSION 60
-#define QLCNIC_LINUX_VERSIONID  "5.3.60"
+#define _QLCNIC_LINUX_SUBVERSION 61
+#define QLCNIC_LINUX_VERSIONID  "5.3.61"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.8.1.4
