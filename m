From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 4/4] forcedeth: version bump and copyright
Date: Fri, 09 Jan 2009 16:03:54 -0500
Message-ID: <4967BBBA.8080109@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090305040105080708020901"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8301 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbZAJAJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 19:09:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090305040105080708020901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch bumps up the version number and adds current year to copyright.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090305040105080708020901
Content-Type: text/plain;
 name="patch-forcedeth-version-copyright"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-version-copyright"

--- old/drivers/net/forcedeth.c	2009-01-09 15:18:12.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-01-09 15:24:11.000000000 -0800
@@ -13,7 +13,7 @@
  * Copyright (C) 2004 Andrew de Quincey (wol support)
  * Copyright (C) 2004 Carl-Daniel Hailfinger (invalid MAC handling, insane
  *		IRQ rate fixes, bigendian fixes, cleanups, verification)
- * Copyright (c) 2004,2005,2006,2007,2008 NVIDIA Corporation
+ * Copyright (c) 2004,2005,2006,2007,2008,2009 NVIDIA Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -39,7 +39,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.61"
+#define FORCEDETH_VERSION		"0.62"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>

--------------090305040105080708020901--
