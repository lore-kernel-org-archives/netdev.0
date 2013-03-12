From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 08/22] cxgb4: Add T5 PCI ids
Date: Tue, 12 Mar 2013 17:16:20 +0530
Message-ID: <1363088794-31453-9-git-send-email-vipul@chelsio.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	naresh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	arvindb-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363088794-31453-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   38 +++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ca88070..eceee44 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -229,6 +229,44 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
 	CH_DEVICE(0x440a, 4),
 	CH_DEVICE(0x440d, 4),
 	CH_DEVICE(0x440e, 4),
+	CH_DEVICE(0x5001, 5),
+	CH_DEVICE(0x5002, 5),
+	CH_DEVICE(0x5003, 5),
+	CH_DEVICE(0x5004, 5),
+	CH_DEVICE(0x5005, 5),
+	CH_DEVICE(0x5006, 5),
+	CH_DEVICE(0x5007, 5),
+	CH_DEVICE(0x5008, 5),
+	CH_DEVICE(0x5009, 5),
+	CH_DEVICE(0x500A, 5),
+	CH_DEVICE(0x500B, 5),
+	CH_DEVICE(0x500C, 5),
+	CH_DEVICE(0x500D, 5),
+	CH_DEVICE(0x500E, 5),
+	CH_DEVICE(0x500F, 5),
+	CH_DEVICE(0x5010, 5),
+	CH_DEVICE(0x5011, 5),
+	CH_DEVICE(0x5012, 5),
+	CH_DEVICE(0x5013, 5),
+	CH_DEVICE(0x5401, 5),
+	CH_DEVICE(0x5402, 5),
+	CH_DEVICE(0x5403, 5),
+	CH_DEVICE(0x5404, 5),
+	CH_DEVICE(0x5405, 5),
+	CH_DEVICE(0x5406, 5),
+	CH_DEVICE(0x5407, 5),
+	CH_DEVICE(0x5408, 5),
+	CH_DEVICE(0x5409, 5),
+	CH_DEVICE(0x540A, 5),
+	CH_DEVICE(0x540B, 5),
+	CH_DEVICE(0x540C, 5),
+	CH_DEVICE(0x540D, 5),
+	CH_DEVICE(0x540E, 5),
+	CH_DEVICE(0x540F, 5),
+	CH_DEVICE(0x5410, 5),
+	CH_DEVICE(0x5411, 5),
+	CH_DEVICE(0x5412, 5),
+	CH_DEVICE(0x5413, 5),
 	{ 0, }
 };
 
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
