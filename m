From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 1/2] cxgb4: Adds device ID for few more Chelsio Adapters
Date: Thu, 27 Mar 2014 18:17:09 +0530
Message-ID: <1395924430-17632-2-git-send-email-hariprasad@chelsio.com>
References: <1395924430-17632-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	kumaras@chelsio.com, santosh@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9829 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753943AbaC0Mz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:55:28 -0400
In-Reply-To: <1395924430-17632-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a7a41e0..6fe5891 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -256,6 +256,12 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x5013, 4),
 	CH_DEVICE(0x5014, 4),
 	CH_DEVICE(0x5015, 4),
+	CH_DEVICE(0x5080, 4),
+	CH_DEVICE(0x5081, 4),
+	CH_DEVICE(0x5082, 4),
+	CH_DEVICE(0x5083, 4),
+	CH_DEVICE(0x5084, 4),
+	CH_DEVICE(0x5085, 4),
 	CH_DEVICE(0x5401, 4),
 	CH_DEVICE(0x5402, 4),
 	CH_DEVICE(0x5403, 4),
@@ -277,6 +283,12 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x5413, 4),
 	CH_DEVICE(0x5414, 4),
 	CH_DEVICE(0x5415, 4),
+	CH_DEVICE(0x5480, 4),
+	CH_DEVICE(0x5481, 4),
+	CH_DEVICE(0x5482, 4),
+	CH_DEVICE(0x5483, 4),
+	CH_DEVICE(0x5484, 4),
+	CH_DEVICE(0x5485, 4),
 	{ 0, }
 };
 
-- 
1.8.4
