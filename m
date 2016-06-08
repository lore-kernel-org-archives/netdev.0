From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Add device id of T540-BT adapter
Date: Wed,  8 Jun 2016 14:57:28 +0530
Message-ID: <1465378048-25868-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:30147 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1161803AbcFHJWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 05:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index a2cdfc1261dc..50812a1d67bd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -144,6 +144,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5015),	/* T502-bt */
 	CH_PCI_ID_TABLE_FENTRY(0x5016),	/* T580-OCP-SO */
 	CH_PCI_ID_TABLE_FENTRY(0x5017),	/* T520-OCP-SO */
+	CH_PCI_ID_TABLE_FENTRY(0x5018),	/* T540-BT */
 	CH_PCI_ID_TABLE_FENTRY(0x5080),	/* Custom T540-cr */
 	CH_PCI_ID_TABLE_FENTRY(0x5081),	/* Custom T540-LL-cr */
 	CH_PCI_ID_TABLE_FENTRY(0x5082),	/* Custom T504-cr */
-- 
2.3.4
