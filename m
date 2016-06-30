From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 5/5] qede: Bump up driver version to 8.10.1.20
Date: Thu, 30 Jun 2016 02:35:22 -0400
Message-ID: <1467268522-24589-6-git-send-email-manish.chopra@qlogic.com>
References: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:7659 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751383AbcF3HTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 03:19:54 -0400
In-Reply-To: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 4e3f1a0..02b06d4 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -24,7 +24,7 @@
 #include <linux/qed/qed_eth_if.h>
 
 #define QEDE_MAJOR_VERSION		8
-#define QEDE_MINOR_VERSION		7
+#define QEDE_MINOR_VERSION		10
 #define QEDE_REVISION_VERSION		1
 #define QEDE_ENGINEERING_VERSION	20
 #define DRV_MODULE_VERSION __stringify(QEDE_MAJOR_VERSION) "."	\
-- 
2.7.2
