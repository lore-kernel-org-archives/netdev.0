From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 08/14] i40e: Minor comment changes
Date: Fri,  1 Aug 2014 13:27:09 -0700
Message-ID: <1406924835-31550-9-git-send-email-aaron.f.brown@intel.com>
References: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60887 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756205AbaHAUX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 16:23:26 -0400
In-Reply-To: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

Fixes comment for reset reason

Change-ID: I6fda4fa292255e6eb0f874502b4d38d722149b10
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 504bdf5..033d853 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -669,7 +669,7 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	 */
 	for (i = 0; i < 100; i++) {
 		/* vf reset requires driver to first reset the
-		 * vf & than poll the status register to make sure
+		 * vf and then poll the status register to make sure
 		 * that the requested op was completed
 		 * successfully
 		 */
-- 
1.9.3
