From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add PCI device ID for new T5 adapter
Date: Tue,  6 Jan 2015 17:31:46 +0530
Message-ID: <1420545706-13763-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30904 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754982AbbAFL4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 06:56:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 9e4f95a..ddfb5b8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -153,6 +153,7 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5086),	/* Custom 2x T580-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5087),	/* Custom T580-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5088),	/* Custom T570-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5089),	/* Custom T520-CR */
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
 #endif /* CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN */
-- 
1.7.1
