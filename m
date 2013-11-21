From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 13/13] bna: Update the Driver Version to 3.2.23.0
Date: Wed, 20 Nov 2013 21:54:17 -0800
Message-ID: <1385013257-32745-14-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55073 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752154Ab3KUGM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:12:29 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 474a597..ea8f1d6 100644
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
