From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] igb: Update version
Date: Tue, 23 Oct 2012 03:24:43 -0700
Message-ID: <1350987887-16161-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10577 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755458Ab2JWKYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 06:24:53 -0400
In-Reply-To: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch updates the igb driver version to 4.0.17.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 87abb57..b07d679 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -61,7 +61,7 @@
 
 #define MAJ 4
 #define MIN 0
-#define BUILD 1
+#define BUILD 17
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
 __stringify(BUILD) "-k"
 char igb_driver_name[] = "igb";
-- 
1.7.11.7
