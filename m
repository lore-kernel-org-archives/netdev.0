From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next 1/2] net: dwc-xlgmac: declaration of dual license in headers
Date: Tue, 21 Mar 2017 11:59:04 +0800
Message-ID: <d8c550bcf611f0350058ea8d6a88f99f8a117f06.1490067991.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds declaration of dual license in file headers.

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
index 726d78a..53ad707 100644
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
index 55c796e..bfe810e 100644
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
index 5cf3e90..e2a58ec 100644
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
