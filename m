From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 09/12] igbvf: update version number
Date: Thu,  9 Jun 2011 20:47:53 -0700
Message-ID: <1307677676-26690-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11153 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914Ab1FJDsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 23:48:04 -0400
In-Reply-To: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Williams, Mitch A" <mitch.a.williams@intel.com>

Update the version number to match version conventions. Bump the major
version to indicate that new hardware support (i350) has been added.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igbvf/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 1c77fb3..64b47bf 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -45,7 +45,7 @@
 
 #include "igbvf.h"
 
-#define DRV_VERSION "1.0.8-k0"
+#define DRV_VERSION "2.0.0-k"
 char igbvf_driver_name[] = "igbvf";
 const char igbvf_driver_version[] = DRV_VERSION;
 static const char igbvf_driver_string[] =
-- 
1.7.5.2

