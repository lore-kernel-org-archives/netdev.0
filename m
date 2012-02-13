From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] e1000e: cleanup: minor whitespace addition (insert blank line separator)
Date: Mon, 13 Feb 2012 13:47:47 -0800
Message-ID: <1329169670-5403-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45312 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755550Ab2BMVr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:59 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e45235e..e2c546d 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3479,6 +3479,7 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	default:
 		break;
 	}
+
 	return e1000e_setup_copper_link(hw);
 }
 
-- 
1.7.7.6
