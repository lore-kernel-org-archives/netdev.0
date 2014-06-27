From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 5/5] cxgb4vf: Adds device ID for few more Chelsio T4 Adapters
Date: Fri, 27 Jun 2014 19:23:51 +0530
Message-ID: <1403877231-8661-6-git-send-email-hariprasad@chelsio.com>
References: <1403877231-8661-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403877231-8661-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index ff1cdd1..f002af1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2924,6 +2924,15 @@ static DEFINE_PCI_DEVICE_TABLE(cxgb4vf_pci_tbl) = {
 	CH_DEVICE(0x480a, 0),   /* T404-bt */
 	CH_DEVICE(0x480d, 0),   /* T480-cr */
 	CH_DEVICE(0x480e, 0),   /* T440-lp-cr */
+	CH_DEVICE(0x4880, 0),
+	CH_DEVICE(0x4880, 1),
+	CH_DEVICE(0x4880, 2),
+	CH_DEVICE(0x4880, 3),
+	CH_DEVICE(0x4880, 4),
+	CH_DEVICE(0x4880, 5),
+	CH_DEVICE(0x4880, 6),
+	CH_DEVICE(0x4880, 7),
+	CH_DEVICE(0x4880, 8),
 	CH_DEVICE(0x5800, 0),	/* T580-dbg */
 	CH_DEVICE(0x5801, 0),	/* T520-cr */
 	CH_DEVICE(0x5802, 0),	/* T522-cr */
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
