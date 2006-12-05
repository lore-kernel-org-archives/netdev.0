From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 4/5] ipw2200: Fix a typo
Date: Tue, 5 Dec 2006 14:41:32 +0800
Message-ID: <20061205064132.GA18281@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28691 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758529AbWLEHJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 02:09:22 -0500
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Pascal Terjan <pterjan@gmail.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2100.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

e4968a3ae9ab96f144c0cc7103699b6ecddd1be0
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index a576a81..d477f7b 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6215,7 +6215,7 @@ static int ipw2100_pci_init_one(struct p
 	/* Allocate and initialize the Tx/Rx queues and lists */
 	if (ipw2100_queues_allocate(priv)) {
 		printk(KERN_WARNING DRV_NAME
-		       "Error calilng ipw2100_queues_allocate.\n");
+		       "Error calling ipw2100_queues_allocate.\n");
 		err = -ENOMEM;
 		goto fail;
 	}
-- 
1.2.6
