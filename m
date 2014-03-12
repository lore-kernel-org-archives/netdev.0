From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] ixgbe: add Linux NICS mailing list to contact info
Date: Tue, 11 Mar 2014 22:53:35 -0700
Message-ID: <1394603618-1044-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40703 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755121AbaCLFxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:44 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch updates the contact information on the ixgbe driver files so
that every file includes the Linux NICS address, as it is still used,
but only a few of the files mentioned it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c   | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h      | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      | 1 +
 23 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 4371ef0..2fff0fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 650d7af..e61aa1f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 82b7462..446df3c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 4456c23..6149c65 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index ef0fd4c..d1d67ba 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
index 05e23b8..bdb99b3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
index d71d9ce..d5a1e3d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index c5933f6..472b0f4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index f2d35c0..24dd6f0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 0872617..39557e3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
index 3a02759..b16cc78 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 0834e1e..2067d39 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 815e81e..851c413 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
index cc3101a..f5c6af2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index e44ff47..a9b9ad6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index d2caae4..ad51c12 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index b4d4323..478eca9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 9ef730f..44ac9ae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index dff0977..e6c68d3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 8bd2919..139eadd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index e74ae36..ef6df3d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index c10382e..69271bc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index eed790a..2e0e5ec 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -20,6 +20,7 @@
   the file called "COPYING".
 
   Contact Information:
+  Linux NICS <linux.nics@intel.com>
   e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
-- 
1.8.3.1
