From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/4] Intel ethernet adapter: Update MAINTAINERS
Date: Mon, 03 Mar 2008 14:37:47 -0800
Message-ID: <20080303223747.16344.11861.stgit@localhost.localdomain>
References: <20080303223731.16344.94975.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44045 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbYCCWhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 17:37:47 -0500
In-Reply-To: <20080303223731.16344.94975.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another team member unfortunately left: update MAINTAINERS.

Condense the 3 lists down to a single list for all our drivers.

Point to our new sourceforge index page which is slightly
better navigateable than the sf.net project page.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 MAINTAINERS |   32 ++++----------------------------
 1 files changed, 4 insertions(+), 28 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2333255..a945724 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2033,43 +2033,19 @@ M:	kernel@wantstofly.org
 L:	netdev@vger.kernel.org
 S:	Maintained
 
-INTEL PRO/100 ETHERNET SUPPORT
+INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/ixgb/ixgbe)
 P:	Auke Kok
 M:	auke-jan.h.kok@intel.com
 P:	Jesse Brandeburg
 M:	jesse.brandeburg@intel.com
 P:	Jeff Kirsher
 M:	jeffrey.t.kirsher@intel.com
+P:	Bruce Allan
+M:	bruce.w.allan@intel.com
 P:	John Ronciak
 M:	john.ronciak@intel.com
 L:	e1000-devel@lists.sourceforge.net
-W:	http://sourceforge.net/projects/e1000/
-S:	Supported
-
-INTEL PRO/1000 GIGABIT ETHERNET SUPPORT
-P:	Auke Kok
-M:	auke-jan.h.kok@intel.com
-P:	Jesse Brandeburg
-M:	jesse.brandeburg@intel.com
-P:	Jeff Kirsher
-M:	jeffrey.t.kirsher@intel.com
-P:	John Ronciak
-M:	john.ronciak@intel.com
-L:	e1000-devel@lists.sourceforge.net
-W:	http://sourceforge.net/projects/e1000/
-S:	Supported
-
-INTEL PRO/10GbE SUPPORT
-P:	Ayyappan Veeraiyan
-M:	ayyappan.veeraiyan@intel.com
-P:	Auke Kok
-M:	auke-jan.h.kok@intel.com
-P:	Jesse Brandeburg
-M:	jesse.brandeburg@intel.com
-P:	John Ronciak
-M:	john.ronciak@intel.com
-L:	e1000-devel@lists.sourceforge.net
-W:	http://sourceforge.net/projects/e1000/
+W:	http://e1000.sourceforge.net/
 S:	Supported
 
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT

