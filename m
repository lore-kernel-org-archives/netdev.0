From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/3] i40e: remove mistaken file
Date: Wed, 15 Jan 2014 15:18:22 -0800
Message-ID: <1389827904-14713-2-git-send-email-aaron.f.brown@intel.com>
References: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
Cc: "Nelson, Shannon" <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49479 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbaAOXSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:18:32 -0500
In-Reply-To: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nelson, Shannon" <shannon.nelson@intel.com>

Remove the Module.symvers that somehow got caught up in 
commit 9d8bf54723e9f21c502a410495840d8771f769ef

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/Module.symvers | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/i40e/Module.symvers

diff --git a/drivers/net/ethernet/intel/i40e/Module.symvers b/drivers/net/ethernet/intel/i40e/Module.symvers
deleted file mode 100644
index e69de29..0000000
-- 
1.8.5.GIT
