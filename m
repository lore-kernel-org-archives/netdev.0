From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 4/5] be2net: Change copyright markings in source files
Date: Wed, 22 Jun 2016 08:54:56 -0400
Message-ID: <1466600097-1641-5-git-send-email-sathya.perla@broadcom.com>
References: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:62538 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752539AbcFVMzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:55:21 -0400
In-Reply-To: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

This patch updates year and company name in the copyright markings in the
be2net source files.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h         | 2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    | 2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 2 +-
 drivers/net/ethernet/emulex/benet/be_main.c    | 2 +-
 drivers/net/ethernet/emulex/benet/be_roce.c    | 2 +-
 drivers/net/ethernet/emulex/benet/be_roce.h    | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 096cb1f5..4555e04 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2015 Emulex
+ * Copyright (C) 2005 - 2016 Broadcom
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index a98b6ab..2cc1175 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2015 Emulex
+ * Copyright (C) 2005 - 2016 Broadcom
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index cb96ddd..0d6be22 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2015 Emulex
+ * Copyright (C) 2005 - 2016 Broadcom
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 71940b9..50e7be5 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2015 Emulex
+ * Copyright (C) 2005 - 2016 Broadcom
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f11a19b..1873c74 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2015 Emulex
+ * Copyright (C) 2005 - 2016 Broadcom
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.c b/drivers/net/ethernet/emulex/benet/be_roce.c
index 4089156..2b62841 100644
--- a/drivers/net/ethernet/emulex/benet/be_roce.c
+++ b/drivers/net/ethernet/emulex/benet/be_roce.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2015 Emulex
+ * Copyright (C) 2005 - 2016 Broadcom
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.h b/drivers/net/ethernet/emulex/benet/be_roce.h
index fde6097..e51719a 100644
--- a/drivers/net/ethernet/emulex/benet/be_roce.h
+++ b/drivers/net/ethernet/emulex/benet/be_roce.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005 - 2015 Emulex
+ * Copyright (C) 2005 - 2016 Broadcom
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or
-- 
2.4.1
