From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 7/7] I/OAT: update driver version and copyright dates
Date: Thu, 26 Feb 2009 11:05:43 +0100
Message-ID: <20090226100538.3615.20360.stgit@linux.site>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21188 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756019AbZBZKOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:14:35 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Together with new fixes update driver version
and extend copyright dates ranges.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.krisher@intel.com>
---

 drivers/dca/dca-core.c          |    2 +-
 drivers/dma/ioat.c              |    2 +-
 drivers/dma/ioat_dca.c          |    2 +-
 drivers/dma/ioat_dma.c          |    2 +-
 drivers/dma/ioatdma.h           |    4 ++--
 drivers/dma/ioatdma_hw.h        |    2 +-
 drivers/dma/ioatdma_registers.h |    2 +-
 7 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/dca/dca-core.c b/drivers/dca/dca-core.c
index 33bd753..25b743a 100644
--- a/drivers/dca/dca-core.c
+++ b/drivers/dca/dca-core.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2007 Intel Corporation. All rights reserved.
+ * Copyright(c) 2007 - 2009 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
diff --git a/drivers/dma/ioat.c b/drivers/dma/ioat.c
index 4105d65..ed83dd9 100644
--- a/drivers/dma/ioat.c
+++ b/drivers/dma/ioat.c
@@ -1,6 +1,6 @@
 /*
  * Intel I/OAT DMA Linux driver
- * Copyright(c) 2007 Intel Corporation.
+ * Copyright(c) 2007 - 2009 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/dma/ioat_dca.c b/drivers/dma/ioat_dca.c
index 78705ca..c012a1e 100644
--- a/drivers/dma/ioat_dca.c
+++ b/drivers/dma/ioat_dca.c
@@ -1,6 +1,6 @@
 /*
  * Intel I/OAT DMA Linux driver
- * Copyright(c) 2007 Intel Corporation.
+ * Copyright(c) 2007 - 2009 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index ae8c0ce..068b635 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -1,6 +1,6 @@
 /*
  * Intel I/OAT DMA Linux driver
- * Copyright(c) 2004 - 2007 Intel Corporation.
+ * Copyright(c) 2004 - 2009 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
index dcf8db5..a52ff4b 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioatdma.h
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2004 - 2007 Intel Corporation. All rights reserved.
+ * Copyright(c) 2004 - 2009 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
@@ -29,7 +29,7 @@ #include <linux/cache.h>
 #include <linux/pci_ids.h>
 #include <net/tcp.h>
 
-#define IOAT_DMA_VERSION  "3.30"
+#define IOAT_DMA_VERSION  "3.64"
 
 enum ioat_interrupt {
 	none = 0,
diff --git a/drivers/dma/ioatdma_hw.h b/drivers/dma/ioatdma_hw.h
index f1ae2c7..afa57ee 100644
--- a/drivers/dma/ioatdma_hw.h
+++ b/drivers/dma/ioatdma_hw.h
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2004 - 2007 Intel Corporation. All rights reserved.
+ * Copyright(c) 2004 - 2009 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
diff --git a/drivers/dma/ioatdma_registers.h b/drivers/dma/ioatdma_registers.h
index 827cb50..49bc277 100644
--- a/drivers/dma/ioatdma_registers.h
+++ b/drivers/dma/ioatdma_registers.h
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2004 - 2007 Intel Corporation. All rights reserved.
+ * Copyright(c) 2004 - 2009 Intel Corporation. All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free

