From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next v2 09/14] i40evf: update version and copyright date
Date: Thu, 20 Feb 2014 19:29:13 -0800
Message-ID: <1392953358-23908-10-git-send-email-aaron.f.brown@intel.com>
References: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4400 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737AbaBUDcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 22:32:17 -0500
In-Reply-To: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

A bunch of changes merit a new version number, and since these were
made in the new year, update the copyright date.

Change-ID: Ic3f282bf0c20679b9fb06860211afa7c78055bc2
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d05d5c1..c4185f0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -31,10 +31,10 @@ char i40evf_driver_name[] = "i40evf";
 static const char i40evf_driver_string[] =
 	"Intel(R) XL710 X710 Virtual Function Network Driver";
 
-#define DRV_VERSION "0.9.11"
+#define DRV_VERSION "0.9.12"
 const char i40evf_driver_version[] = DRV_VERSION;
 static const char i40evf_copyright[] =
-	"Copyright (c) 2013 Intel Corporation.";
+	"Copyright (c) 2013 - 2014 Intel Corporation.";
 
 /* i40evf_pci_tbl - PCI Device ID Table
  *
-- 
1.8.5.GIT
