From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 5/6] igb: Update license text to remove FSF address and update copyright.
Date: Tue, 25 Feb 2014 17:58:57 -0800
Message-ID: <1393379938-1415-6-git-send-email-aaron.f.brown@intel.com>
References: <1393379938-1415-1-git-send-email-aaron.f.brown@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48765 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbaBZCCS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 21:02:18 -0500
In-Reply-To: <1393379938-1415-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch updates the license text to remove address of Free Software
Foundation and refer  users to www.gnu.org instead. This patch also updates
the copyright dates in appropriate igb driver files.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/igb/Makefile        | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_82575.h   | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_defines.h | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_hw.h      | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_i210.c    | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_i210.h    | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_mac.c     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_mac.h     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_mbx.c     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_mbx.h     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_nvm.c     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_nvm.h     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_phy.h     | 5 ++---
 drivers/net/ethernet/intel/igb/e1000_regs.h    | 5 ++---
 drivers/net/ethernet/intel/igb/igb.h           | 5 ++---
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 5 ++---
 drivers/net/ethernet/intel/igb/igb_hwmon.c     | 5 ++---
 drivers/net/ethernet/intel/igb/igb_main.c      | 7 +++----
 drivers/net/ethernet/intel/igb/igb_ptp.c       | 5 ++---
 21 files changed, 43 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
index f19700e..5bcb2de 100644
--- a/drivers/net/ethernet/intel/igb/Makefile
+++ b/drivers/net/ethernet/intel/igb/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel 82575 PCI-Express Ethernet Linux driver
-# Copyright(c) 1999 - 2013 Intel Corporation.
+# Copyright(c) 1999 - 2014 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
 # more details.
 #
 # You should have received a copy of the GNU General Public License along with
-# this program; if not, write to the Free Software Foundation, Inc.,
-# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+# this program; if not, see <http://www.gnu.org/licenses/>.
 #
 # The full GNU General Public License is included in this distribution in
 # the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 0ee7049..45947b3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 622d80d..f12b086 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 0571b97..393c896 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index ab99e2b..10741d1 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 9f32c78..db96339 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.h b/drivers/net/ethernet/intel/igb/e1000_i210.h
index a068866..907fe99 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.h
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 298f0ed..5910a93 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.h b/drivers/net/ethernet/intel/igb/e1000_mac.h
index e4cbe8e..99299ba 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.c b/drivers/net/ethernet/intel/igb/e1000_mbx.c
index dac1447..d5b1217 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.h b/drivers/net/ethernet/intel/igb/e1000_mbx.h
index de9bba4..f52f551 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.h
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.c b/drivers/net/ethernet/intel/igb/e1000_nvm.c
index a7db7f3..9abf829 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.c
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.h b/drivers/net/ethernet/intel/igb/e1000_nvm.h
index 433b741..5b10117 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.h
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index c0f2a16..4009bba 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index 55b3f8c..4c2c36c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 82632c6..abdd935 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 65f3c77..fc3fc2c 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 1df0237..c7f5741 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
index e0af5bc..8333f67 100644
--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 84dfa3f..3384156 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel(R) Gigabit Ethernet Linux driver
-  Copyright(c) 2007-2013 Intel Corporation.
+  Copyright(c) 2007-2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -13,8 +13,7 @@
   more details.
 
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+  this program; if not, see <http://www.gnu.org/licenses/>.
 
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
@@ -70,7 +69,7 @@ char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
 				"Intel(R) Gigabit Ethernet Network Driver";
 static const char igb_copyright[] =
-				"Copyright (c) 2007-2013 Intel Corporation.";
+				"Copyright (c) 2007-2014 Intel Corporation.";
 
 static const struct e1000_info *igb_info_tbl[] = {
 	[board_82575] = &e1000_82575_info,
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index d9f3976..9c9c141 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -12,9 +12,8 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
  */
 #include <linux/module.h>
 #include <linux/device.h>
-- 
1.8.5.GIT
