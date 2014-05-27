From: Ariel Elior <ariel.elior@qlogic.com>
Subject: [PATCH net-next] bnx2x: update MAINTAINERS for bnx2x and e-mail addresses
Date: Tue, 27 May 2014 13:11:36 +0300
Message-ID: <1401185496-29539-1-git-send-email-ariel.elior@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:64210 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751128AbaE0KLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 06:11:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x development team has transferred from Broadcom to Qlogic.
This patch updates some obsolete email addresses to usable ones.
The bnx2x files contain headers with legal information from
Broadcom. Qlogic Legal depratment is taking their time coming up
with their own legal info. So this patch only updates contact
information. I will follow up with a patch for the headers once I
have the required info.

Signed-off-by: Ariel Elior <ariel.elior@qlogic.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h    |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 .../ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h    |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h   |    4 ++--
 .../net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h   |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h  |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c   |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h   |    4 ++--
 19 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index bde15ff..5694e62 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1888,7 +1888,7 @@ F:	drivers/net/ethernet/broadcom/bnx2.*
 F:	drivers/net/ethernet/broadcom/bnx2_*
 
 BROADCOM BNX2X 10 GIGABIT ETHERNET DRIVER
-M:	Ariel Elior <ariele@broadcom.com>
+M:	Ariel Elior <ariel.elior@qlogic.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/ethernet/broadcom/bnx2x/
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 4d8f8ab..4cab09d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9261d53..d18441e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 3448cc0..571427c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 97ea542..51a952c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Dmitry Kravkov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
index 804b8f6..c6939ec 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Dmitry Kravkov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 0322409..5203a89 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
index f572ae1..8aafd9b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
@@ -6,8 +6,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
- * Written by: Vladislav Zolotarov <vladz@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
+ * Written by: Vladislav Zolotarov
  * Based on the original idea of John Wright <john.wright@hp.com>.
  */
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
index c2dfea7..bd90e50 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
@@ -7,9 +7,9 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
- * Modified by: Vladislav Zolotarov <vladz@broadcom.com>
+ * Modified by: Vladislav Zolotarov
  */
 
 #ifndef BNX2X_INIT_H
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
index 8ab0dd9..5669ed2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
@@ -8,8 +8,8 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
- * Written by: Vladislav Zolotarov <vladz@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
+ * Written by: Vladislav Zolotarov
  */
 
 #ifndef BNX2X_INIT_OPS_H
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 3b0d431..ff2bdd8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 3129726..736264b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Vladislav Zolotarov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 80f6c79..718ecd2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -12,7 +12,7 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Vladislav Zolotarov
  *
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 81cc2d9..57bbbab 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -12,9 +12,9 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
- * Written by: Shmulik Ravid <shmulikr@broadcom.com>
- *	       Ariel Elior <ariele@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
+ * Written by: Shmulik Ravid
+ *	       Ariel Elior <ariel.elior@qlogic.com>
  *
  */
 #include "bnx2x.h"
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index cd4d624..96c575e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -12,9 +12,9 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
- * Written by: Shmulik Ravid <shmulikr@broadcom.com>
- *	       Ariel Elior <ariele@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
+ * Written by: Shmulik Ravid
+ *	       Ariel Elior <ariel.elior@qlogic.com>
  */
 #ifndef BNX2X_SRIOV_H
 #define BNX2X_SRIOV_H
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 3b75070..ca47665 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index f358450..2beceae 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 0c067e8..bf0c817 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -12,9 +12,9 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
- * Written by: Shmulik Ravid <shmulikr@broadcom.com>
- *	       Ariel Elior <ariele@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
+ * Written by: Shmulik Ravid
+ *	       Ariel Elior <ariel.elior@qlogic.com>
  */
 
 #include "bnx2x.h"
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index c922b81..e21e706 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -12,8 +12,8 @@
  * license other than the GPL, without Broadcom's express prior written
  * consent.
  *
- * Maintained by: Eilon Greenstein <eilong@broadcom.com>
- * Written by: Ariel Elior <ariele@broadcom.com>
+ * Maintained by: Ariel Elior <ariel.elior@qlogic.com>
+ * Written by: Ariel Elior <ariel.elior@qlogic.com>
  */
 #ifndef VF_PF_IF_H
 #define VF_PF_IF_H
-- 
1.7.1
