From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 5/5] qlcnic: Update version to 5.2.46.
Date: Thu, 15 Aug 2013 08:27:29 -0400
Message-ID: <1376569649-565-6-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59011 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756298Ab3HONKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:10:45 -0400
In-Reply-To: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 3935155..7387354 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -37,8 +37,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 2
-#define _QLCNIC_LINUX_SUBVERSION 45
-#define QLCNIC_LINUX_VERSIONID  "5.2.45"
+#define _QLCNIC_LINUX_SUBVERSION 46
+#define QLCNIC_LINUX_VERSIONID  "5.2.46"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.8.1.4
