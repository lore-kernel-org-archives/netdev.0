From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 8/8] cxgb4: Add more PCI device ids.
Date: Tue, 18 Feb 2014 17:56:15 +0530
Message-ID: <1392726375-32001-9-git-send-email-hariprasad@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31324 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755265AbaBRNgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:36:08 -0500
In-Reply-To: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 654ff3a..3c95288 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -254,6 +254,8 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x5011, 4),
 	CH_DEVICE(0x5012, 4),
 	CH_DEVICE(0x5013, 4),
+	CH_DEVICE(0x5014, 4),
+	CH_DEVICE(0x5015, 4),
 	CH_DEVICE(0x5401, 4),
 	CH_DEVICE(0x5402, 4),
 	CH_DEVICE(0x5403, 4),
@@ -273,6 +275,8 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x5411, 4),
 	CH_DEVICE(0x5412, 4),
 	CH_DEVICE(0x5413, 4),
+	CH_DEVICE(0x5414, 4),
+	CH_DEVICE(0x5415, 4),
 	{ 0, }
 };
 
-- 
1.8.0
