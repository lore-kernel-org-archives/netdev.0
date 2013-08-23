From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 5/5] qlcnic: Update version to 5.3.49.
Date: Fri, 23 Aug 2013 13:38:29 -0400
Message-ID: <1377279509-18869-6-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1377279509-18869-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:5968 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754760Ab3HWSHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 14:07:09 -0400
In-Reply-To: <1377279509-18869-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 3364924..156a78e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 3
-#define _QLCNIC_LINUX_SUBVERSION 48
-#define QLCNIC_LINUX_VERSIONID  "5.3.48"
+#define _QLCNIC_LINUX_SUBVERSION 49
+#define QLCNIC_LINUX_VERSIONID  "5.3.49"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.8.1.4
