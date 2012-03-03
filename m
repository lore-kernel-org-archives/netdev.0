From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] e1000e: cleanup incorrect filename in comment
Date: Fri,  2 Mar 2012 18:24:21 -0800
Message-ID: <1330741468-23900-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47073 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018Ab2CCCYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:34 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 8b62870..efb3729 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6628,4 +6628,4 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-/* e1000_main.c */
+/* netdev.c */
-- 
1.7.7.6
