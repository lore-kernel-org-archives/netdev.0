From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next 1/2] net: dwc-xlgmac: declaration of dual license in headers
Date: Thu, 23 Mar 2017 12:03:45 +0800
Message-ID: <eed57e46080bcf76715eb19b3d58efcace8dc324.1490239652.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:42549 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdCWEES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 00:04:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver "dwc-xlgmac" is dual-licensed. This patch adds
declaration of dual license in file headers.

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
 drivers/net/ethernet/synopsys/dwc-xlgmac-common.c | 6 ++----
 drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c   | 6 ++----
 drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c     | 6 ++----
 drivers/net/ethernet/synopsys/dwc-xlgmac-net.c    | 6 ++----
 drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c    | 6 ++----
 drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h    | 6 ++----
 drivers/net/ethernet/synopsys/dwc-xlgmac.h        | 6 ++----
 7 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
index b72196a..cb11928 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
@@ -2,10 +2,8 @@
  *
  * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
  *
- * This program is free software; you can redistribute it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
  *
  * This Synopsys DWC XLGMAC software driver and associated documentation
  * (hereinafter the "Software") is an unsupported proprietary work of
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
index 39b5cb9..e9672b1 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-desc.c
@@ -2,10 +2,8 @@
  *
  * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
  *
- * This program is free software; you can redistribute it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
  *
  * This Synopsys DWC XLGMAC software driver and associated documentation
  * (hereinafter the "Software") is an unsupported proprietary work of
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
index 1e25a86..0dec1dc 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
@@ -2,10 +2,8 @@
  *
  * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
  *
- * This program is free software; you can redistribute it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
  *
  * This Synopsys DWC XLGMAC software driver and associated documentation
  * (hereinafter the "Software") is an unsupported proprietary work of
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
index 5e8428b..6acf86c 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
@@ -2,10 +2,8 @@
  *
  * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
  *
- * This program is free software; you can redistribute it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
  *
  * This Synopsys DWC XLGMAC software driver and associated documentation
  * (hereinafter the "Software") is an unsupported proprietary work of
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c
index 504e80d..386bafe 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-pci.c
@@ -2,10 +2,8 @@
  *
  * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
  *
- * This program is free software; you can redistribute it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
  *
  * This Synopsys DWC XLGMAC software driver and associated documentation
  * (hereinafter the "Software") is an unsupported proprietary work of
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h b/drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h
index 7824481..3754f22 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-reg.h
@@ -2,10 +2,8 @@
  *
  * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
  *
- * This program is free software; you can redistribute it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
  *
  * This Synopsys DWC XLGMAC software driver and associated documentation
  * (hereinafter the "Software") is an unsupported proprietary work of
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac.h b/drivers/net/ethernet/synopsys/dwc-xlgmac.h
index 7a4dc64..676b2fb8 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac.h
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac.h
@@ -2,10 +2,8 @@
  *
  * Copyright (c) 2017 Synopsys, Inc. (www.synopsys.com)
  *
- * This program is free software; you can redistribute it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
+ * This program is dual-licensed; you may select either version 2 of
+ * the GNU General Public License ("GPL") or BSD license ("BSD").
  *
  * This Synopsys DWC XLGMAC software driver and associated documentation
  * (hereinafter the "Software") is an unsupported proprietary work of
-- 
1.9.1
