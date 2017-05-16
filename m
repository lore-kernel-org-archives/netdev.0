From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: add new T5 pci device id
Date: Tue, 16 May 2017 21:39:05 +0530
Message-ID: <1494950945-19148-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:61011 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdEPQJL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:09:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index a323185..9232bec 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -172,6 +172,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x509e), /* Custom T520-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x509f), /* Custom T540-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x50a0), /* Custom T540-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x50a1), /* Custom T540-CR */
 
 	/* T6 adapters:
 	 */
-- 
2.1.0
