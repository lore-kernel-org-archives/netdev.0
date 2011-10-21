From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/5] igbvf: Bump version number
Date: Fri, 21 Oct 2011 03:31:58 -0700
Message-ID: <1319193121-2729-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30637 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205Ab1JUKcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 06:32:06 -0400
In-Reply-To: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Williams, Mitch A" <mitch.a.williams@intel.com>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 10e3c9c..cca7812 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -45,7 +45,7 @@
 
 #include "igbvf.h"
 
-#define DRV_VERSION "2.0.0-k"
+#define DRV_VERSION "2.0.1-k"
 char igbvf_driver_name[] = "igbvf";
 const char igbvf_driver_version[] = DRV_VERSION;
 static const char igbvf_driver_string[] =
-- 
1.7.6.4
