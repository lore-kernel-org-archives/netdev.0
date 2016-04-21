From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] fm10k: consistently use Intel(R) for driver names
Date: Wed, 20 Apr 2016 23:09:28 -0700
Message-ID: <1461218969-68578-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbcDUGJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:36 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Update every header file and other locations to consistently use
Intel(R) instead of just Intel. Also update copyright year of files
which we modified.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile        | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_common.c  | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_common.h  | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c   | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h     | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h      | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c     | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h     | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h      | 2 +-
 20 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index 2aeaa39..cac6453 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -1,6 +1,6 @@
 ################################################################################
 #
-# Intel Ethernet Switch Host Interface Driver
+# Intel(R) Ethernet Switch Host Interface Driver
 # Copyright(c) 2013 - 2016 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
@@ -22,7 +22,7 @@
 ################################################################################
 
 #
-# Makefile for the Intel(R) FM10000 Ethernet Switch Host Interface driver
+# Makefile for the Intel(R) Ethernet Switch Host Interface Driver
 #
 
 obj-$(CONFIG_FM10K) += fm10k.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 5efae40..fcf106e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.c b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
index 6cfae6a..5bbf19c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.h b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
index 45e4e5b..50f71e9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c b/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
index 2be4361..db4bd8b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
index 5d6137f..5116fd0 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index e79e915..9c0d875 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index bbf7c4b..47f0743 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index aca3e47..b875f42 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
@@ -34,7 +34,7 @@ const char fm10k_driver_version[] = DRV_VERSION;
 char fm10k_driver_name[] = "fm10k";
 static const char fm10k_driver_string[] = DRV_SUMMARY;
 static const char fm10k_copyright[] =
-	"Copyright (c) 2013 Intel Corporation.";
+	"Copyright (c) 2013 - 2016 Intel Corporation.";
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION(DRV_SUMMARY);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 98202c3..c9dfa65 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
index 245a0a3..b7dbc8a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index bf229d5..2a08d3f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 1d83378..404f47a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 2105cb8..5b0ceec 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index d4a3465..3336d3c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
index 6b500a63..f8e87bf 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
index e1845e0..a1f1027 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
@@ -1,5 +1,5 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+/* Intel(R) Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index f3f37a4..b8bc061 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 0440706..3b06685e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
index f0932f9..2662f33 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
@@ -1,4 +1,4 @@
-/* Intel Ethernet Switch Host Interface Driver
+/* Intel(R) Ethernet Switch Host Interface Driver
  * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
-- 
2.5.5
