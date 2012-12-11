From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 7/7] bna: Driver Version Updated to 3.1.2.1
Date: Tue, 11 Dec 2012 14:24:56 -0800
Message-ID: <1355264696-8927-8-git-send-email-rmody@brocade.com>
References: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, <David.Laight@ACULAB.COM>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39547 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755057Ab2LKWZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:25:38 -0500
In-Reply-To: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 134d534..72ba586 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -71,7 +71,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"3.0.23.0"
+#define BNAD_VERSION			"3.1.2.1"
 
 #define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
-- 
1.7.1
