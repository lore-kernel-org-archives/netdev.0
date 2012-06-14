From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] net: remove my future former mail address
Date: Thu, 14 Jun 2012 11:29:03 +0300
Message-ID: <1339662543-7203-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>,
	=?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>,
	Sakari Ailus <sakari.ailus@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oyp.chewa.net ([91.121.6.101]:49338 "EHLO oyp.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239Ab2FNIjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 04:39:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi@remlab.net>
Cc: Sakari Ailus <sakari.ailus@nokia.com>
---
 include/net/phonet/gprs.h |    2 +-
 net/caif/caif_dev.c       |    3 +--
 net/phonet/af_phonet.c    |    4 ++--
 net/phonet/datagram.c     |    4 ++--
 net/phonet/pep-gprs.c     |    2 +-
 net/phonet/pep.c          |    2 +-
 net/phonet/pn_dev.c       |    4 ++--
 net/phonet/pn_netlink.c   |    4 ++--
 net/phonet/socket.c       |    4 ++--
 net/phonet/sysctl.c       |    2 +-
 10 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/net/phonet/gprs.h b/include/net/phonet/gprs.h
index 928daf5..bcd525e 100644
--- a/include/net/phonet/gprs.h
+++ b/include/net/phonet/gprs.h
@@ -5,7 +5,7 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Author: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Author: R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index aa6f716..554b312 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -4,8 +4,7 @@
  * Author:	Sjur Brendeland/sjur.brandeland@stericsson.com
  * License terms: GNU General Public License (GPL) version 2
  *
- * Borrowed heavily from file: pn_dev.c. Thanks to
- *  Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Borrowed heavily from file: pn_dev.c. Thanks to Remi Denis-Courmont
  *  and Sakari Ailus <sakari.ailus@nokia.com>
  */
=20
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 779ce4f..5a940db 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -5,8 +5,8 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
- * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ * Authors: Sakari Ailus <sakari.ailus@nokia.com>
+ *          R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index bf35b4e..12c30f3 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -5,8 +5,8 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
- * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ * Authors: Sakari Ailus <sakari.ailus@nokia.com>
+ *          R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index d012089..a2fba7e 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -5,7 +5,7 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Author: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Author: R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 9dd4f92..576f22c 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -5,7 +5,7 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Author: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Author: R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 36f75a9..5bf6341 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -5,8 +5,8 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
- * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ * Authors: Sakari Ailus <sakari.ailus@nokia.com>
+ *          R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index cfdf135..7dd762a 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -5,8 +5,8 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
- * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ * Authors: Sakari Ailus <sakari.ailus@nokia.com>
+ *          Remi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 89cfa9c..0acc943 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -5,8 +5,8 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
- * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ * Authors: Sakari Ailus <sakari.ailus@nokia.com>
+ *          R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index 696348f..d6bbbbd 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -5,7 +5,7 @@
  *
  * Copyright (C) 2008 Nokia Corporation.
  *
- * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Author: R=C3=A9mi Denis-Courmont
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
--=20
1.7.9.5
