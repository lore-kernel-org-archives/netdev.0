From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/5] cnic: Update version to 2.5.18.
Date: Mon, 2 Sep 2013 11:42:32 -0700
Message-ID: <1378147352-9076-6-git-send-email-mchan@broadcom.com>
References: <1378147352-9076-1-git-send-email-mchan@broadcom.com>
 <1378147352-9076-2-git-send-email-mchan@broadcom.com>
 <1378147352-9076-3-git-send-email-mchan@broadcom.com>
 <1378147352-9076-4-git-send-email-mchan@broadcom.com>
 <1378147352-9076-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4751 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756551Ab3IBSWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 14:22:20 -0400
In-Reply-To: <1378147352-9076-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic_if.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 95aff76..0658b43 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.17"
-#define CNIC_MODULE_RELDATE	"July 28, 2013"
+#define CNIC_MODULE_VERSION	"2.5.18"
+#define CNIC_MODULE_RELDATE	"Sept 01, 2013"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
