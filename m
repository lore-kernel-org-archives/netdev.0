From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 3/4] netxen: fix license header
Date: Thu, 14 Jan 2010 02:43:06 -0800
Message-ID: <1263465787-28203-4-git-send-email-amit.salecha@qlogic.com>
References: <1263465787-28203-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:56164 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755993Ab0ANKnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 05:43:11 -0500
In-Reply-To: <1263465787-28203-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GNU General Public License is in file "COPYING".

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/Makefile             |    2 +-
 drivers/net/netxen/netxen_nic.h         |    2 +-
 drivers/net/netxen/netxen_nic_ctx.c     |    2 +-
 drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
 drivers/net/netxen/netxen_nic_hdr.h     |    2 +-
 drivers/net/netxen/netxen_nic_hw.c      |    2 +-
 drivers/net/netxen/netxen_nic_hw.h      |    2 +-
 drivers/net/netxen/netxen_nic_init.c    |    2 +-
 drivers/net/netxen/netxen_nic_main.c    |    2 +-
 9 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netxen/Makefile b/drivers/net/netxen/Makefile
index 11d94e2..861a059 100644
--- a/drivers/net/netxen/Makefile
+++ b/drivers/net/netxen/Makefile
@@ -18,7 +18,7 @@
 # MA  02111-1307, USA.
 # 
 # The full GNU General Public License is included in this distribution
-# in the file called LICENSE.
+# in the file called "COPYING".
 # 
 #
 
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index c5a03a6..6dd33eb 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 9cb8f68..2a8ef5f 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 542f408..f8499e5 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index d138fc2..4d17579 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9548e59..dd45c7a 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 3fd1dcb..e2c5b6f 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 64cff68..c8dceaf 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2d584ea..2173f98 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -19,7 +19,7 @@
  * MA  02111-1307, USA.
  *
  * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
+ * in the file called "COPYING".
  *
  */
 
-- 
1.6.0.2

