From: Cloud Ren <cjren@qca.qualcomm.com>
Subject: [PATCH 2/3] atl1c: change author
Date: Thu, 1 Mar 2012 13:41:08 +0800
Message-ID: <1330580469-23348-3-git-send-email-cjren@qca.qualcomm.com>
References: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	Cloud Ren <cjren@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:41011 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755112Ab2CAFlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 00:41:39 -0500
In-Reply-To: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The author, jie yang, has left. please use nic-devel@qualcomm.com report bugs to
us.

Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 6bf387b..815f683 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -52,7 +52,7 @@ static DEFINE_PCI_DEVICE_TABLE(atl1c_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
 
-MODULE_AUTHOR("Jie Yang <jie.yang@atheros.com>");
+MODULE_AUTHOR("Qualcomm Corporation, <nic-devel@qualcomm.com>");
 MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
 MODULE_LICENSE("GPL");
 
-- 
1.7.7
