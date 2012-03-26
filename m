From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 7/7] bna: Update driver version to 3.0.23.0
Date: Mon, 26 Mar 2012 12:41:03 -0700
Message-ID: <1332790863-10577-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:47676 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754274Ab2CZTlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 15:41:10 -0400
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
