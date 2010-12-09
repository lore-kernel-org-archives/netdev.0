From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 7/7] e1000e: cleanup: fix copyright notices to
	preferred style
Date: Thu,  9 Dec 2010 02:40:57 +0000
Message-ID: <1291862457-16671-8-git-send-email-asbjorn__5987.44746898792$1291863653$gmane$org@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Reformat the copyright notices in e1001e, to follow the preferred style
for multi-line comments, as outlined in Documentation/CodingStyle.

Prior to 0c73b4e, the current style generated an "Missing space after"
warning per line.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/82571.c   |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/defines.h |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/e1000.h   |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/es2lan.c  |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/ethtool.c |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/hw.h      |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/ich8lan.c |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/lib.c     |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/netdev.c  |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/param.c   |   52 +++++++++++++++++++++---------------------
 drivers/net/e1000e/phy.c     |   52 +++++++++++++++++++++---------------------
 11 files changed, 286 insertions(+), 286 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index bbc73ce..2b36af4 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 /*
  * 82571EB Gigabit Ethernet Controller
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index f1260fc..4035598 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 #ifndef _E1000_DEFINES_H_
 #define _E1000_DEFINES_H_
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 97fa58a..f2bea0f 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 /* Linux PRO/1000 Ethernet Driver main header file */
 
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 56a1321..3bc9df7 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 /*
  * 80003ES2LAN Gigabit Ethernet Controller (Copper)
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 4fee336..3096bbd 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 /* ethtool support for e1000 */
 
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index f009dd5..3911717 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 #ifndef _E1000_HW_H_
 #define _E1000_HW_H_
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index a1dec6c..b90f5b1 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 /*
  * 82562G 10/100 Network Connection
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index b950db3..5e85855 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 #include "e1000.h"
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index bdd3774..c0803cb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 992be2b..f069021 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 #include <linux/netdevice.h>
 #include <linux/pci.h>
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 23b1e48..45111c1 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1,30 +1,30 @@
 /*******************************************************************************
-
-  Intel PRO/1000 Linux driver
-  Copyright(c) 1999 - 2010 Intel Corporation.
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Contact Information:
-  Linux NICS <linux.nics@intel.com>
-  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
-  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
-
-*******************************************************************************/
+ *
+ * Intel PRO/1000 Linux driver
+ * Copyright(c) 1999 - 2010 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * Linux NICS <linux.nics@intel.com>
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
 
 #include <linux/delay.h>
 
-- 
1.7.2.3


------------------------------------------------------------------------------
This SF Dev2Dev email is sponsored by:

WikiLeaks The End of the Free Internet
http://p.sf.net/sfu/therealnews-com
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
