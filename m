From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add PCI device ID for custom T522 & T520 adapter
Date: Wed, 17 Jun 2015 14:40:04 +0530
Message-ID: <1434532204-30479-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7796 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750971AbbFQD4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 23:56:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index 1a9a6f3..d7ca106 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -153,6 +153,8 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5088),	/* Custom T570-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5089),	/* Custom T520-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5090),	/* Custom T540-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5091),	/* Custom T522-CR */
+	CH_PCI_ID_TABLE_FENTRY(0x5092),	/* Custom T520-CR */
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
 #endif /* __T4_PCI_ID_TBL_H__ */
-- 
2.3.4
