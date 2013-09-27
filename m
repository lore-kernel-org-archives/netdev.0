From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v3 net-next 2/2] qlge: Update version to 1.00.00.33
Date: Fri, 27 Sep 2013 13:17:47 -0400
Message-ID: <1380302267-27843-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1380302267-27843-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40150 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753513Ab3I0Rrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 13:47:49 -0400
In-Reply-To: <1380302267-27843-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index cc62272..f1af4d6 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -18,7 +18,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00.32"
+#define DRV_VERSION	"1.00.00.33"
 
 #define WQ_ADDR_ALIGN	0x3	/* 4 byte alignment */
 
-- 
1.7.6.rc1.1.g2c162b
