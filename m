From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Add PCI device ID for new adapter
Date: Tue, 29 Nov 2016 17:14:52 +0530
Message-ID: <1480419892-30842-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com,
        swise@opengridcomputing.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:54530 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754270AbcK2LjT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 06:39:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index df1573c4a659..ecf3ccc257bc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -168,6 +168,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x509a),	/* Custom T520-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x509b),	/* Custom T540-CR LOM */
 	CH_PCI_ID_TABLE_FENTRY(0x509c),	/* Custom T520-CR*/
+	CH_PCI_ID_TABLE_FENTRY(0x509d),	/* Custom T540-CR*/
 
 	/* T6 adapters:
 	 */
-- 
2.3.4
