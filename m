From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 7/7] bna: Update driver version to 3.0.23.0
Date: Wed, 4 Apr 2012 08:44:31 -0700
Message-ID: <1333554271-23038-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <AdapterLinuxOpenSrcExtTeam@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:38437 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932288Ab2DDPof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 11:44:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver version update

Signed-off-by: Jing Huang <huangj@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index d73967a..72742be 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -71,7 +71,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"3.0.2.2"
+#define BNAD_VERSION			"3.0.23.0"
 
 #define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
-- 
1.6.5.2
