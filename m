From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: correct device ID of T6 adapter
Date: Wed,  2 Nov 2016 10:52:53 +0530
Message-ID: <1478064173-21453-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:16885 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbcKBFQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 01:16:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 50812a1d67bd..df1573c4a659 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -178,9 +178,9 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x6005),
 	CH_PCI_ID_TABLE_FENTRY(0x6006),
 	CH_PCI_ID_TABLE_FENTRY(0x6007),
+	CH_PCI_ID_TABLE_FENTRY(0x6008),
 	CH_PCI_ID_TABLE_FENTRY(0x6009),
 	CH_PCI_ID_TABLE_FENTRY(0x600d),
-	CH_PCI_ID_TABLE_FENTRY(0x6010),
 	CH_PCI_ID_TABLE_FENTRY(0x6011),
 	CH_PCI_ID_TABLE_FENTRY(0x6014),
 	CH_PCI_ID_TABLE_FENTRY(0x6015),
-- 
2.3.4
