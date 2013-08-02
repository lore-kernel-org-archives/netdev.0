From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v3 5/5] qlcnic: Update version to 5.2.45
Date: Fri, 2 Aug 2013 00:57:43 -0400
Message-ID: <3e41ed74f4ac1e25852c322a2dca0f269a83b320.1375438720.git.himanshu.madhani@qlogic.com>
References: <cover.1375438720.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:25919 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754492Ab3HBFZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 01:25:28 -0400
In-Reply-To: <cover.1375438720.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index cd95442..eae41bc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -37,8 +37,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 2
-#define _QLCNIC_LINUX_SUBVERSION 44
-#define QLCNIC_LINUX_VERSIONID  "5.2.44"
+#define _QLCNIC_LINUX_SUBVERSION 45
+#define QLCNIC_LINUX_VERSIONID  "5.2.45"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.8.1.4
