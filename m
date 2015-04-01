From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net][resubmit] MAINTAINERS: Update Intel Wired Ethernet Driver info
Date: Tue, 31 Mar 2015 21:42:30 -0700
Message-ID: <1427863350-22108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux.nics@intel.com, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the git tree info with a recent change in tree names.  Also
add our new mailing list created solely for Linux kernel patches
and kernel development, as well as the new patchwork project for
tracking patches.  Lastly update the list of "reviewers" since a
couple of developers have moved on to different projects.

Made an update to the section header so that it is more manageable
going forward as we add new drivers.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 358eb01..9508870 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5128,22 +5128,21 @@ M:	Deepak Saxena <dsaxena@plexity.net>
 S:	Maintained
 F:	drivers/char/hw_random/ixp4xx-rng.c
 
-INTEL ETHERNET DRIVERS (e100/e1000/e1000e/fm10k/igb/igbvf/ixgb/ixgbe/ixgbevf/i40e/i40evf)
+INTEL ETHERNET DRIVERS
 M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
-M:	Jesse Brandeburg <jesse.brandeburg@intel.com>
-M:	Bruce Allan <bruce.w.allan@intel.com>
-M:	Carolyn Wyborny <carolyn.wyborny@intel.com>
-M:	Don Skidmore <donald.c.skidmore@intel.com>
-M:	Greg Rose <gregory.v.rose@intel.com>
-M:	Matthew Vick <matthew.vick@intel.com>
-M:	John Ronciak <john.ronciak@intel.com>
-M:	Mitch Williams <mitch.a.williams@intel.com>
-M:	Linux NICS <linux.nics@intel.com>
-L:	e1000-devel@lists.sourceforge.net
+R:	Jesse Brandeburg <jesse.brandeburg@intel.com>
+R:	Shannon Nelson <shannon.nelson@intel.com>
+R:	Carolyn Wyborny <carolyn.wyborny@intel.com>
+R:	Don Skidmore <donald.c.skidmore@intel.com>
+R:	Matthew Vick <matthew.vick@intel.com>
+R:	John Ronciak <john.ronciak@intel.com>
+R:	Mitch Williams <mitch.a.williams@intel.com>
+L:	intel-wired-lan@lists.osuosl.org
 W:	http://www.intel.com/support/feedback.htm
 W:	http://e1000.sourceforge.net/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net.git
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
+Q:	http://patchwork.ozlabs.org/project/intel-wired-lan/list/
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
 S:	Supported
 F:	Documentation/networking/e100.txt
 F:	Documentation/networking/e1000.txt
-- 
1.9.3
