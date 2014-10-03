From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] Update Intel Ethernet Driver maintainers list
Date: Fri, 03 Oct 2014 14:45:00 -0700
Message-ID: <20141003213835.147369.71088.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: matthew.vick@intel.com, jeffrey.t.kirsher@intel.com,
	alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14792 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932238AbaJCVxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 17:53:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will no longer be working for Intel as of today.  As such I am removing
myself from the maintainers list and adding my replacement, Matthew Vick
as he will be taking over maintenance of the fm10k driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

Just wanted to send this out as a notice, I have internally submitted a copy
of this for Jeff Kirsher's tree to have submitted via a pull request.  I
should only be without a corporate email for a day or two and will likely be
back up on my new email account early next week.  In the meantime I will still
be on the netdev list via my gmail account.

 MAINTAINERS |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c2e7a06..e36f464 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4784,14 +4784,14 @@ M:	Deepak Saxena <dsaxena@plexity.net>
 S:	Maintained
 F:	drivers/char/hw_random/ixp4xx-rng.c
 
-INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe/ixgbevf/i40e/i40evf)
+INTEL ETHERNET DRIVERS (e100/e1000/e1000e/fm10k/igb/igbvf/ixgb/ixgbe/ixgbevf/i40e/i40evf)
 M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
 M:	Jesse Brandeburg <jesse.brandeburg@intel.com>
 M:	Bruce Allan <bruce.w.allan@intel.com>
 M:	Carolyn Wyborny <carolyn.wyborny@intel.com>
 M:	Don Skidmore <donald.c.skidmore@intel.com>
 M:	Greg Rose <gregory.v.rose@intel.com>
-M:	Alex Duyck <alexander.h.duyck@intel.com>
+M:	Matthew Vick <matthew.vick@intel.com>
 M:	John Ronciak <john.ronciak@intel.com>
 M:	Mitch Williams <mitch.a.williams@intel.com>
 M:	Linux NICS <linux.nics@intel.com>
