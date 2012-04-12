From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH] drivers/net/ethernet/xilinx/axi ethernet: Correct Copyright
Date: Thu, 12 Apr 2012 13:11:12 +0200
Message-ID: <1334229072-8581-1-git-send-email-monstr@monstr.eu>
Cc: netdev@vger.kernel.org, John.Linn@xilinx.com,
	danborkmann@iogearbox.net, anirudh@xilinx.com,
	Michal Simek <monstr@monstr.eu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:64947 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179Ab2DLLLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 07:11:19 -0400
Received: by wibhj6 with SMTP id hj6so5364845wib.1
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 04:11:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also fix MAINTAINERS file to reflect autorship.

Daniel and Ariane changed coding style but not any functional changes in the driver
itself.

Signed-off-by: Michal Simek <monstr@monstr.eu>
---
 MAINTAINERS                                       |    4 ++--
 drivers/net/ethernet/xilinx/xilinx_axienet.h      |    4 +---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    6 +++---
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c |    6 +++---
 4 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index a127097..5d15fa6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7573,8 +7573,8 @@ F:	Documentation/filesystems/xfs.txt
 F:	fs/xfs/
 
 XILINX AXI ETHERNET DRIVER
-M:	Ariane Keller <ariane.keller@tik.ee.ethz.ch>
-M:	Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
+M:	Anirudha Sarangi <anirudh@xilinx.com>
+M:	John Linn <John.Linn@xilinx.com>
 S:	Maintained
 F:	drivers/net/ethernet/xilinx/xilinx_axienet*
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
index cc83af0..44b8d2b 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -2,9 +2,7 @@
  * Definitions for Xilinx Axi Ethernet device driver.
  *
  * Copyright (c) 2009 Secret Lab Technologies, Ltd.
- * Copyright (c) 2010 Xilinx, Inc. All rights reserved.
- * Copyright (c) 2012 Daniel Borkmann, <daniel.borkmann@tik.ee.ethz.ch>
- * Copyright (c) 2012 Ariane Keller, <ariane.keller@tik.ee.ethz.ch>
+ * Copyright (c) 2010 - 2012 Xilinx, Inc. All rights reserved.
  */
 
 #ifndef XILINX_AXIENET_H
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 2fcbeba..9c365e1 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -4,9 +4,9 @@
  * Copyright (c) 2008 Nissin Systems Co., Ltd.,  Yoshio Kashiwagi
  * Copyright (c) 2005-2008 DLA Systems,  David H. Lynch Jr. <dhlii@dlasys.net>
  * Copyright (c) 2008-2009 Secret Lab Technologies Ltd.
- * Copyright (c) 2010 Xilinx, Inc. All rights reserved.
- * Copyright (c) 2012 Daniel Borkmann, <daniel.borkmann@tik.ee.ethz.ch>
- * Copyright (c) 2012 Ariane Keller, <ariane.keller@tik.ee.ethz.ch>
+ * Copyright (c) 2010 - 2011 Michal Simek <monstr@monstr.eu>
+ * Copyright (c) 2010 - 2011 PetaLogix
+ * Copyright (c) 2010 - 2012 Xilinx, Inc. All rights reserved.
  *
  * This is a driver for the Xilinx Axi Ethernet which is used in the Virtex6
  * and Spartan6.
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
index d70b6e7..e90e1f4 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
@@ -2,9 +2,9 @@
  * MDIO bus driver for the Xilinx Axi Ethernet device
  *
  * Copyright (c) 2009 Secret Lab Technologies, Ltd.
- * Copyright (c) 2010 Xilinx, Inc. All rights reserved.
- * Copyright (c) 2012 Daniel Borkmann, <daniel.borkmann@tik.ee.ethz.ch>
- * Copyright (c) 2012 Ariane Keller, <ariane.keller@tik.ee.ethz.ch>
+ * Copyright (c) 2010 - 2011 Michal Simek <monstr@monstr.eu>
+ * Copyright (c) 2010 - 2011 PetaLogix
+ * Copyright (c) 2010 - 2012 Xilinx, Inc. All rights reserved.
  */
 
 #include <linux/of_address.h>
-- 
1.7.10.rc3.1.gb306
