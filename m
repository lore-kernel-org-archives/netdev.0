From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH] net headers: export dcbnl.h
Date: Thu, 26 Feb 2009 16:54:35 -0800
Message-ID: <20090227005435.10551.85504.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61601 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140AbZB0Ayh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 19:54:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DCB netlink interface is required for building the userspace tools
available at e1000.sourceforge.net

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 include/linux/Kbuild |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index b97cdc5..106c3ba 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -52,6 +52,7 @@ header-y += const.h
 header-y += cgroupstats.h
 header-y += cramfs_fs.h
 header-y += cycx_cfm.h
+header-y += dcbnl.h
 header-y += dlmconstants.h
 header-y += dlm_device.h
 header-y += dlm_netlink.h

