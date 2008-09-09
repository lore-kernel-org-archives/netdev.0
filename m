From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/9] PCI VPD related patches
Date: Tue, 09 Sep 2008 11:20:40 -0700
Message-ID: <20080909182040.246073057@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:37565 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753135AbYIIT3U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 15:29:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Updated patch set to cover PCI VPD routines and show two examples
of usage. Patch is for 2.6.28, so it is against kernel that
already includes netdev patches for next merge window:
netdev-2.6 upstream-next branch.

It is in three logical chunks:
   1-3 PCI related patches
   4-6 sky2 driver
   7-9 skge driver
-- 

