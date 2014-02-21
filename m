From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 6/7] qlcnic: Update version to 5.3.56
Date: Fri, 21 Feb 2014 08:19:54 -0500
Message-ID: <1392988795-19380-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1392988795-19380-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:2958 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932222AbaBUNzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 08:55:46 -0500
In-Reply-To: <1392988795-19380-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 6ad1bce..df9daa3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -38,8 +38,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 3
-#define _QLCNIC_LINUX_SUBVERSION 55
-#define QLCNIC_LINUX_VERSIONID  "5.3.55"
+#define _QLCNIC_LINUX_SUBVERSION 56
+#define QLCNIC_LINUX_VERSIONID  "5.3.56"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
-- 
1.8.1.4
