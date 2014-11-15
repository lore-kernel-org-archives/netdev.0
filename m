From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] i40e: Bump version to 1.1.23
Date: Fri, 14 Nov 2014 22:08:27 -0800
Message-ID: <1416031715-32498-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64147 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbaKOGIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:40 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Bumping minor version as this will be the second SW release and it
should be 1.

Change-ID: If0bd102095d2f059ae0c9b7f4ad625535ffbbdee
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index de66463..6608289 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -38,8 +38,8 @@ static const char i40e_driver_string[] =
 #define DRV_KERN "-k"
 
 #define DRV_VERSION_MAJOR 1
-#define DRV_VERSION_MINOR 0
-#define DRV_VERSION_BUILD 21
+#define DRV_VERSION_MINOR 1
+#define DRV_VERSION_BUILD 23
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
-- 
1.9.3
