From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: add new T6 pci device id's
Date: Tue,  3 Oct 2017 11:10:53 +0530
Message-ID: <1507009253-6686-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:37081 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750787AbdJCFks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 01:40:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 0x6085 T6 device id.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 37d90d6..633e975 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -202,6 +202,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x6082), /* Custom T6225-CR SFP28 */
 	CH_PCI_ID_TABLE_FENTRY(0x6083), /* Custom T62100-CR QSFP28 */
 	CH_PCI_ID_TABLE_FENTRY(0x6084), /* Custom T64100-CR QSFP28 */
+	CH_PCI_ID_TABLE_FENTRY(0x6085), /* Custom T6240-SO */
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
 #endif /* __T4_PCI_ID_TBL_H__ */
-- 
2.1.0
