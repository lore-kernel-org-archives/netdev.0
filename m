From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH] dca: add missing copyright/license headers
Date: Thu, 19 Mar 2009 17:03:06 +0100
Message-ID: <20090319160244.24380.31212.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57345 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbZCSQL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 12:11:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In two dca files copyright and license headers are missing.
This patch adds them there.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>
---

 drivers/dca/dca-sysfs.c |   21 +++++++++++++++++++++
 include/linux/dca.h     |   20 ++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/dca/dca-sysfs.c b/drivers/dca/dca-sysfs.c
index bb538b9..ee916c9 100644
--- a/drivers/dca/dca-sysfs.c
+++ b/drivers/dca/dca-sysfs.c
@@ -1,3 +1,24 @@
+/*
+ * Copyright(c) 2007 - 2009 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ */
+
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/device.h>
diff --git a/include/linux/dca.h b/include/linux/dca.h
index b00a753..9c20c7e 100644
--- a/include/linux/dca.h
+++ b/include/linux/dca.h
@@ -1,3 +1,23 @@
+/*
+ * Copyright(c) 2007 - 2009 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ */
 #ifndef DCA_H
 #define DCA_H
 /* DCA Provider API */

