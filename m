From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: add new T5 pci device id
Date: Tue, 30 May 2017 11:50:40 +0530
Message-ID: <1496125240-7439-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:51717 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdE3GUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 02:20:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 9232bec..be7041f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -173,6 +173,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x509f), /* Custom T540-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x50a0), /* Custom T540-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x50a1), /* Custom T540-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x50a2), /* Custom T540-KR4 */
 
 	/* T6 adapters:
 	 */
-- 
2.1.0
