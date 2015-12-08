From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 7/7] cxgb4: Adds PCI device id for new T5 adapters
Date: Tue,  8 Dec 2015 10:09:17 +0530
Message-ID: <1449549557-16023-8-git-send-email-hariprasad@chelsio.com>
References: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:9954 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932691AbbLHEiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 23:38:23 -0500
In-Reply-To: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 03ed00c..a8dda63 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -162,6 +162,9 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5095),	/* Custom T540-CR-SO */
 	CH_PCI_ID_TABLE_FENTRY(0x5096),	/* Custom T580-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5097),	/* Custom T520-KR */
+	CH_PCI_ID_TABLE_FENTRY(0x5098),	/* Custom 2x40G QSFP */
+	CH_PCI_ID_TABLE_FENTRY(0x5099),	/* Custom 2x40G QSFP */
+	CH_PCI_ID_TABLE_FENTRY(0x509a),	/* Custom T520-CR */
 
 	/* T6 adapters:
 	 */
-- 
2.3.4
