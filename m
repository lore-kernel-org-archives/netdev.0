From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net-next 1/2] be2net: Modify GPL Marking in all source files.
Date: Tue, 22 Jan 2013 13:44:08 +0530
Message-ID: <d01bcb2c-5921-4324-a28a-fe0d0729bf49@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:30712 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464Ab3AVINa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 03:13:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |   25 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   25 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   25 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   25 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_hw.h      |   25 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_main.c    |   25 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_roce.c    |   25 ++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_roce.h    |   25 ++++++++++++++----------
 8 files changed, 120 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4eba17b..f27fe8e 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.  The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 #ifndef BE_H
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8a250c3..d1222a4 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.  The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index d6552e1..9bd9aa5 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.  The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 /*
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 76b302f..6ea33a0 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.  The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 #include "be.h"
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 541d453..e490f73 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.  The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 /********* Mailbox door bell *************/
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5c99570..b1cc3f2 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.  The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 #include <linux/prefetch.h>
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.c b/drivers/net/ethernet/emulex/benet/be_roce.c
index 55d32aa..ebc39a9 100644
--- a/drivers/net/ethernet/emulex/benet/be_roce.c
+++ b/drivers/net/ethernet/emulex/benet/be_roce.c
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation. The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 #include <linux/mutex.h>
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.h b/drivers/net/ethernet/emulex/benet/be_roce.h
index db4ea80..3b57976 100644
--- a/drivers/net/ethernet/emulex/benet/be_roce.h
+++ b/drivers/net/ethernet/emulex/benet/be_roce.h
@@ -1,18 +1,23 @@
 /*
- * Copyright (C) 2005 - 2011 Emulex
- * All rights reserved.
+ * This file is part of the Linux NIC driver for Emulex OneConnect CNA.
  *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation. The full GNU General
- * Public License is included in this distribution in the file called COPYING.
+ * Copyright (C) 2005-2013 Emulex. All rights reserved.
  *
- * Contact Information:
+ * EMULEX and SLI are trademarks of Emulex.
+ * www.emulex.com
  * linux-drivers@emulex.com
  *
- * Emulex
- * 3333 Susan Street
- * Costa Mesa, CA 92626
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful.
+ * ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES,
+ * INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A
+ * PARTICULAR PURPOSE, OR NON-INFRINGEMENT, ARE DISCLAIMED, EXCEPT TO THE
+ * EXTENT THAT SUCH DISCLAIMERS ARE HELD TO BE LEGALLY INVALID.
+ * See the GNU General Public License for more details, a copy of which
+ * can be found in the file COPYING included with this package
  */
 
 #ifndef BE_ROCE_H
-- 
1.7.9.5
