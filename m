From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 12/12] bna: Update the Driver Version to 3.2.23.0
Date: Thu, 12 Dec 2013 17:54:38 -0800
Message-ID: <1386899678-18591-13-git-send-email-rmody@brocade.com>
References: <1386899678-18591-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36491 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752012Ab3LMBz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 20:55:57 -0500
In-Reply-To: <1386899678-18591-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index e174e22..1896924 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -71,7 +71,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"3.2.21.1"
+#define BNAD_VERSION			"3.2.23.0"
 
 #define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
-- 
1.8.2.3
