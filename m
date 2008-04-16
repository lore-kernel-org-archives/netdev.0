From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: Increment version to 0.2.1
Date: Wed, 16 Apr 2008 11:49:31 -0700
Message-ID: <20080416184931.4188.61766.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42641 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbYDPStf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 14:49:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 7282751..5110382 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -46,7 +46,7 @@
 
 #include "e1000.h"
 
-#define DRV_VERSION "0.2.0"
+#define DRV_VERSION "0.2.1"
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 

