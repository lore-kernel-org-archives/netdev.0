From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 01/12] atl1c: update author contact info & company/driver desciption
Date: Wed, 18 Apr 2012 13:32:25 +0800
Message-ID: <1334727156-6830-2-git-send-email-xiong@qca.qualcomm.com>
References: <1334727156-6830-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334727156-6830-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

replace unavailable email of the author since he left with a mail-list.
update company info as well, Atheros was acquired by Qualcomm.
insert "100" to driver description since it support 100M controller.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 1ef0c92..1f1f9eb 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -54,8 +54,9 @@ static DEFINE_PCI_DEVICE_TABLE(atl1c_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
 
-MODULE_AUTHOR("Jie Yang <jie.yang@atheros.com>");
-MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
+MODULE_AUTHOR("Jie Yang");
+MODULE_AUTHOR("Qualcomm Atheros Inc., <nic-devel@qualcomm.com>");
+MODULE_DESCRIPTION("Qualcom Atheros 100/1000M Ethernet Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ATL1C_DRV_VERSION);
 
-- 
1.7.7
