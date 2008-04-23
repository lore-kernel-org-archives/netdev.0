From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/8] e1000e: Increment version to 0.2.1
Date: Wed, 23 Apr 2008 11:09:39 -0700
Message-ID: <20080423180939.24972.97195.stgit@localhost.localdomain>
References: <20080423180900.24972.84015.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20865 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926AbYDWSJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 14:09:40 -0400
In-Reply-To: <20080423180900.24972.84015.stgit@localhost.localdomain>
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
 

