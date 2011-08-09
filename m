From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 8/8] bna: Driver Version changed to 3.0.2.0
Date: Mon, 8 Aug 2011 19:21:42 -0700
Message-ID: <1312856502-31242-9-git-send-email-rmody@brocade.com>
References: <1312856502-31242-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:50098 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751577Ab1HICWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 22:22:22 -0400
In-Reply-To: <1312856502-31242-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index a538cf4..5b5451e 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -67,7 +67,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"2.3.2.3"
+#define BNAD_VERSION			"3.0.2.0"
 
 #define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
-- 
1.7.1

