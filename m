From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] e1000e: cosmetic comment changes to make lines less than 80 characters
Date: Fri, 24 Feb 2012 02:13:07 -0800
Message-ID: <1330078389-8203-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41098 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756798Ab2BXKNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:19 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 3c2daa7..1f8f852 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -289,7 +289,7 @@ static void e1000_release_phy_80003es2lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_acquire_mac_csr_80003es2lan - Acquire rights to access Kumeran register
+ *  e1000_acquire_mac_csr_80003es2lan - Acquire right to access Kumeran register
  *  @hw: pointer to the HW structure
  *
  *  Acquire the semaphore to access the Kumeran interface.
@@ -305,7 +305,7 @@ static s32 e1000_acquire_mac_csr_80003es2lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000_release_mac_csr_80003es2lan - Release rights to access Kumeran Register
+ *  e1000_release_mac_csr_80003es2lan - Release right to access Kumeran Register
  *  @hw: pointer to the HW structure
  *
  *  Release the semaphore used to access the Kumeran interface
-- 
1.7.7.6
