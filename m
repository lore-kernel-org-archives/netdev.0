From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6.27-rc8 6/6] e1000e: update version from k4 to k6
Date: Thu, 02 Oct 2008 16:33:45 -0700
Message-ID: <20081002233345.12556.64335.stgit@jbrandeb-bw.jf.intel.com>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tglx@linutronix.de, arjan@linux.intel.com, airlied@gmail.com,
	davem@davemloft.net, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9487 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872AbYJBXd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 19:33:58 -0400
In-Reply-To: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 01e9558..b81c423 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -47,7 +47,7 @@
 
 #include "e1000.h"
 
-#define DRV_VERSION "0.3.3.3-k4"
+#define DRV_VERSION "0.3.3.3-k6"
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 

