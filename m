From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: add new T5 pci device id's
Date: Tue, 10 Oct 2017 12:45:02 +0530
Message-ID: <1507619702-8793-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:13869 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbdJJHPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 03:15:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 0x50aa and 0x50ab T5 device id's.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 37d90d6..c660c1a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -181,6 +181,8 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x50a7), /* Custom T580-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x50a8), /* Custom T580-KR */
 	CH_PCI_ID_TABLE_FENTRY(0x50a9), /* Custom T580-KR */
+	CH_PCI_ID_TABLE_FENTRY(0x50aa), /* Custom T580-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x50ab), /* Custom T520-CR */
 
 	/* T6 adapters:
 	 */
-- 
2.1.0
