From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] e1000e: cleanup incorrect filename in comment
Date: Wed, 29 Feb 2012 23:33:02 -0800
Message-ID: <1330587188-28717-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330587188-28717-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59683 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757085Ab2CAHdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 02:33:15 -0500
In-Reply-To: <1330587188-28717-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
