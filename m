From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 2/2] net headers: export dcbnl.h
Date: Fri, 27 Feb 2009 12:01:42 -0800
Message-ID: <20090227200141.31557.37591.stgit@localhost.localdomain>
References: <20090227200136.31557.53143.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15329 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757934AbZB0UBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 15:01:43 -0500
In-Reply-To: <20090227200136.31557.53143.stgit@localhost.localdomain>
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

