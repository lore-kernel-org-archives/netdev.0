From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 3/4] igb: bump version to igb-5.4.0
Date: Tue, 27 Sep 2016 19:05:00 -0700
Message-ID: <1475028301-122700-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1475028301-122700-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:27491 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933703AbcI1CFF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 22:05:05 -0400
In-Reply-To: <1475028301-122700-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Bump igb version to match other igb drivers.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a83aa13..edc9a6a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -58,7 +58,7 @@
 #include "igb.h"
 
 #define MAJ 5
-#define MIN 3
+#define MIN 4
 #define BUILD 0
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." \
 __stringify(BUILD) "-k"
-- 
2.7.4
