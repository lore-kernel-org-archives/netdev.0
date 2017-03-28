From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: fix copyright holder
Date: Tue, 28 Mar 2017 15:10:36 -0400
Message-ID: <20170328191036.18551-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51498 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753284AbdC1TMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 15:12:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do not hold the copyright of the DSA core and drivers source files,
since these changes have been written as an initiative of my day job.
Fix this.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 3 +++
 drivers/net/dsa/mv88e6xxx/global1.c | 3 ++-
 drivers/net/dsa/mv88e6xxx/global1.h | 3 ++-
 drivers/net/dsa/mv88e6xxx/global2.c | 3 ++-
 drivers/net/dsa/mv88e6xxx/global2.h | 3 ++-
 drivers/net/dsa/mv88e6xxx/port.c    | 3 ++-
 drivers/net/dsa/mv88e6xxx/port.h    | 3 ++-
 net/dsa/switch.c                    | 3 ++-
 8 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2bca297d9296..ef3495cb8826 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -8,6 +8,9 @@
  *
  * Copyright (c) 2016 Andrew Lunn <andrew@lunn.ch>
  *
+ * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 75af86a7fad8..39825837a1c9 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -3,7 +3,8 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index eece7418e67d..e30cbe480d5b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -3,7 +3,8 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 8f15bc7b1f5f..0b8601f8536e 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -4,7 +4,8 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index a8b2f9486a4a..f8b6dd93213a 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -3,7 +3,8 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index d4868bb50ed5..548a956637ee 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -3,7 +3,8 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index c2425ddab287..86f40887b6d2 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -3,7 +3,8 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index 6456dacf9ae9..7b6f38e5fef6 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -1,7 +1,8 @@
 /*
  * Handling of a single switch chip, part of a switch fabric
  *
- * Copyright (c) 2017 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ * Copyright (c) 2017 Savoir-faire Linux Inc.
+ *	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
2.12.1
