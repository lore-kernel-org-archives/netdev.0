From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 11/11] ibm_newemac: Update file headers copyright notices
Date: Wed, 05 Dec 2007 11:14:33 +1100
Message-ID: <20071205001543.4F018DE135@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51626 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbXLEAQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 19:16:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updates the copyright notices of the new EMAC driver to
avoid confusion as who is to be blamed for new bugs.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 
 drivers/net/ibm_newemac/core.c  |    5 +++++
 drivers/net/ibm_newemac/core.h  |    5 +++++
 drivers/net/ibm_newemac/debug.c |    5 +++++
 drivers/net/ibm_newemac/debug.h |    5 +++++
 drivers/net/ibm_newemac/emac.h  |    5 +++++
 drivers/net/ibm_newemac/mal.c   |    5 +++++
 drivers/net/ibm_newemac/mal.h   |    5 +++++
 drivers/net/ibm_newemac/phy.c   |    5 +++++
 drivers/net/ibm_newemac/phy.h   |    5 +++++
 drivers/net/ibm_newemac/rgmii.c |    5 +++++
 drivers/net/ibm_newemac/rgmii.h |    5 +++++
 drivers/net/ibm_newemac/tah.c   |    5 +++++
 drivers/net/ibm_newemac/tah.h   |    5 +++++
 drivers/net/ibm_newemac/zmii.c  |    5 +++++
 drivers/net/ibm_newemac/zmii.h  |    5 +++++
 15 files changed, 75 insertions(+)

Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2007-11-30 15:35:50.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.c	2007-11-30 16:03:30.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/core.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.h	2007-11-30 15:35:50.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.h	2007-11-30 16:03:23.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/debug.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/debug.c	2007-11-30 15:35:50.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/debug.c	2007-11-30 16:03:18.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/debug.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/debug.h	2007-11-30 15:35:50.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/debug.h	2007-11-30 16:03:15.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/emac.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/emac.h	2007-11-30 15:35:50.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/emac.h	2007-11-30 16:03:09.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Register definitions for PowerPC 4xx on-chip ethernet contoller
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/mal.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/mal.c	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/mal.c	2007-11-30 16:03:02.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Memory Access Layer (MAL) support
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/mal.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/mal.h	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/mal.h	2007-11-30 16:02:55.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Memory Access Layer (MAL) support
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/phy.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/phy.c	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/phy.c	2007-11-30 16:02:47.000000000 +1100
@@ -8,6 +8,11 @@
  * This file should be shared with other drivers or eventually
  * merged as the "low level" part of miilib
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * (c) 2003, Benjamin Herrenscmidt (benh@kernel.crashing.org)
  * (c) 2004-2005, Eugene Surovegin <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/phy.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/phy.h	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/phy.h	2007-11-30 16:02:32.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, PHY support
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Benjamin Herrenschmidt <benh@kernel.crashing.org>
  * February 2003
  *
Index: linux-work/drivers/net/ibm_newemac/rgmii.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/rgmii.c	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/rgmii.c	2007-11-30 16:02:23.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/rgmii.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/rgmii.h	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/rgmii.h	2007-11-30 16:02:19.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Based on ocp_zmii.h/ibm_emac_zmii.h
  * Armin Kuster akuster@mvista.com
  *
Index: linux-work/drivers/net/ibm_newemac/tah.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/tah.c	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/tah.c	2007-11-30 16:02:11.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright 2004 MontaVista Software, Inc.
  * Matt Porter <mporter@kernel.crashing.org>
  *
Index: linux-work/drivers/net/ibm_newemac/tah.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/tah.h	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/tah.h	2007-11-30 16:02:06.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright 2004 MontaVista Software, Inc.
  * Matt Porter <mporter@kernel.crashing.org>
  *
Index: linux-work/drivers/net/ibm_newemac/zmii.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/zmii.c	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/zmii.c	2007-11-30 16:01:53.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
Index: linux-work/drivers/net/ibm_newemac/zmii.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/zmii.h	2007-11-30 15:35:51.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/zmii.h	2007-11-30 16:01:33.000000000 +1100
@@ -3,6 +3,11 @@
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
  *
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * Based on the arch/ppc version of the driver:
+ *
  * Copyright (c) 2004, 2005 Zultys Technologies.
  * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
  *
