From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 1/1] bna: firmware update to 3.2.1.1
Date: Fri, 23 Aug 2013 14:31:30 -0700
Message-ID: <1377293490-7583-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40280 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755799Ab3HWVoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 17:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the firmware to address the thermal notification issue

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/cna.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index c37f706..43405f6 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -37,8 +37,8 @@
 
 extern char bfa_version[];
 
-#define CNA_FW_FILE_CT	"ctfw-3.2.1.0.bin"
-#define CNA_FW_FILE_CT2	"ct2fw-3.2.1.0.bin"
+#define CNA_FW_FILE_CT	"ctfw-3.2.1.1.bin"
+#define CNA_FW_FILE_CT2	"ct2fw-3.2.1.1.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
 #pragma pack(1)
-- 
1.8.3.rc2
