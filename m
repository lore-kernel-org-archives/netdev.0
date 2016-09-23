From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/5] igbvf: bump version to igbvf-2.4.0
Date: Thu, 22 Sep 2016 23:38:58 -0700
Message-ID: <1474612741-75681-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25937 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753439AbcIWGjD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 02:39:03 -0400
In-Reply-To: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Bump version to match other igbvf drivers.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index b0778ba..12bb877 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -47,7 +47,7 @@
 
 #include "igbvf.h"
 
-#define DRV_VERSION "2.0.2-k"
+#define DRV_VERSION "2.4.0-k"
 char igbvf_driver_name[] = "igbvf";
 const char igbvf_driver_version[] = DRV_VERSION;
 static const char igbvf_driver_string[] =
-- 
2.7.4
