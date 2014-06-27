From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 4/5] cxgb4: Adds device ID for few more Chelsio T4 Adapters
Date: Fri, 27 Jun 2014 19:23:50 +0530
Message-ID: <1403877231-8661-5-git-send-email-hariprasad@chelsio.com>
References: <1403877231-8661-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:49373
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753855AbaF0Nsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 09:48:33 -0400
In-Reply-To: <1403877231-8661-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 74ef0e6..921f805 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -224,6 +224,17 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x4008, -1),
 	CH_DEVICE(0x4009, -1),
 	CH_DEVICE(0x400a, -1),
+	CH_DEVICE(0x400d, -1),
+	CH_DEVICE(0x400e, -1),
+	CH_DEVICE(0x4080, -1),
+	CH_DEVICE(0x4081, -1),
+	CH_DEVICE(0x4082, -1),
+	CH_DEVICE(0x4083, -1),
+	CH_DEVICE(0x4084, -1),
+	CH_DEVICE(0x4085, -1),
+	CH_DEVICE(0x4086, -1),
+	CH_DEVICE(0x4087, -1),
+	CH_DEVICE(0x4088, -1),
 	CH_DEVICE(0x4401, 4),
 	CH_DEVICE(0x4402, 4),
 	CH_DEVICE(0x4403, 4),
@@ -236,6 +247,15 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x440a, 4),
 	CH_DEVICE(0x440d, 4),
 	CH_DEVICE(0x440e, 4),
+	CH_DEVICE(0x4480, 4),
+	CH_DEVICE(0x4481, 4),
+	CH_DEVICE(0x4482, 4),
+	CH_DEVICE(0x4483, 4),
+	CH_DEVICE(0x4484, 4),
+	CH_DEVICE(0x4485, 4),
+	CH_DEVICE(0x4486, 4),
+	CH_DEVICE(0x4487, 4),
+	CH_DEVICE(0x4488, 4),
 	CH_DEVICE(0x5001, 4),
 	CH_DEVICE(0x5002, 4),
 	CH_DEVICE(0x5003, 4),
-- 
1.7.1
