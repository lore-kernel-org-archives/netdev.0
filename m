From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] MAINTAINERS: Cleanup Intel Wired LAN maintainers list
Date: Wed,  4 May 2016 15:49:39 -0700
Message-ID: <1462402179-125720-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15870 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753670AbcEDWtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 18:49:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the recent "retirements" and other changes, make the maintainers
list a lot less confusing and a bit more straight forward.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Shannon Nelson <sln@onemain.com>
---
 MAINTAINERS | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2b74fde..e425912 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5748,13 +5748,6 @@ F:	drivers/char/hw_random/ixp4xx-rng.c
 
 INTEL ETHERNET DRIVERS
 M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
-R:	Jesse Brandeburg <jesse.brandeburg@intel.com>
-R:	Shannon Nelson <shannon.nelson@intel.com>
-R:	Carolyn Wyborny <carolyn.wyborny@intel.com>
-R:	Don Skidmore <donald.c.skidmore@intel.com>
-R:	Bruce Allan <bruce.w.allan@intel.com>
-R:	John Ronciak <john.ronciak@intel.com>
-R:	Mitch Williams <mitch.a.williams@intel.com>
 L:	intel-wired-lan@lists.osuosl.org (moderated for non-subscribers)
 W:	http://www.intel.com/support/feedback.htm
 W:	http://e1000.sourceforge.net/
-- 
2.5.5
